import { Injectable, HttpStatus } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

export interface HealthCheckResult {
  status: 'ok' | 'error';
  info?: Record<string, any>;
  error?: Record<string, any>;
  details: Record<string, any>;
}

@Injectable()
export class HealthService {
  private startTime = Date.now();

  constructor(private readonly prisma: PrismaService) {}

  async check(): Promise<HealthCheckResult> {
    const checks = {
      database: await this.checkDatabase(),
      memory: this.checkMemory(),
      uptime: this.checkUptime(),
    };

    const hasErrors = Object.values(checks).some(check => check.status !== 'up' && check.status !== 'ok');

    return {
      status: hasErrors ? 'error' : 'ok',
      info: hasErrors ? {} : checks,
      error: hasErrors ? checks : {},
      details: checks,
    };
  }

  async readinessCheck() {
    const timestamp = new Date().toISOString();
    
    try {
      // Check database connectivity
      const dbCheck = await this.checkDatabase();
      const isDatabaseReady = dbCheck.status === 'up';

      // Check environment variables
      const envCheck = this.checkEnvironment();
      const isEnvironmentReady = envCheck.status === 'ok';

      // Check if all critical dependencies are available
      const dependenciesCheck = await this.checkDependencies();
      const areDependenciesReady = dependenciesCheck.status === 'ok';

      const isReady = isDatabaseReady && isEnvironmentReady && areDependenciesReady;

      return {
        status: isReady ? 'ready' : 'not_ready',
        checks: {
          database: isDatabaseReady,
          environment: isEnvironmentReady,
          dependencies: areDependenciesReady,
        },
        details: {
          database: dbCheck,
          environment: envCheck,
          dependencies: dependenciesCheck,
        },
        timestamp,
      };
    } catch (error: any) {
      return {
        status: 'not_ready',
        error: error.message,
        timestamp,
      };
    }
  }

  async livenessCheck() {
    // Simple liveness check - if the service can respond, it's alive
    return {
      status: 'alive',
      timestamp: new Date().toISOString(),
      version: process.env.npm_package_version || '1.0.0',
      uptime: this.formatUptime(Date.now() - this.startTime),
    };
  }

  private async checkDatabase() {
    const startTime = Date.now();
    
    try {
      // Simple database connectivity check
      await this.prisma.$queryRaw`SELECT 1`;
      const responseTime = Date.now() - startTime;
      
      return {
        status: 'up',
        responseTime: `${responseTime}ms`,
      };
    } catch (error: any) {
      return {
        status: 'down',
        error: error.message,
        responseTime: `${Date.now() - startTime}ms`,
      };
    }
  }

  private checkMemory() {
    const memoryUsage = process.memoryUsage();
    const heapUsedMB = (memoryUsage.heapUsed / 1024 / 1024).toFixed(1);
    const heapTotalMB = (memoryUsage.heapTotal / 1024 / 1024).toFixed(1);
    const rssMB = (memoryUsage.rss / 1024 / 1024).toFixed(1);

    // Consider memory usage critical if heap used exceeds 1GB
    const isMemoryOk = memoryUsage.heapUsed < 1024 * 1024 * 1024;

    return {
      status: isMemoryOk ? 'ok' : 'warning',
      heapUsed: `${heapUsedMB} MB`,
      heapTotal: `${heapTotalMB} MB`,
      rss: `${rssMB} MB`,
    };
  }

  private checkUptime() {
    const uptimeMs = Date.now() - this.startTime;
    const formattedUptime = this.formatUptime(uptimeMs);

    return {
      status: 'ok',
      uptime: formattedUptime,
      uptimeMs,
    };
  }

  private checkEnvironment() {
    const requiredEnvVars = [
      'DATABASE_URL',
      'JWT_SECRET',
    ];

    const missingVars = requiredEnvVars.filter(varName => !process.env[varName]);
    const hasAllRequired = missingVars.length === 0;

    return {
      status: hasAllRequired ? 'ok' : 'error',
      required: requiredEnvVars,
      missing: missingVars,
      nodeEnv: process.env.NODE_ENV || 'development',
    };
  }

  private async checkDependencies() {
    // Check if critical modules are available and working
    try {
      // Test JWT functionality
      const jwt = require('jsonwebtoken');
      jwt.sign({ test: true }, 'test-secret', { expiresIn: '1m' });

      // Test bcrypt functionality  
      const bcrypt = require('bcrypt');
      await bcrypt.hash('test', 1);

      return {
        status: 'ok',
        jwt: 'available',
        bcrypt: 'available',
        prisma: 'available',
      };
    } catch (error: any) {
      return {
        status: 'error',
        error: error.message,
      };
    }
  }

  private formatUptime(uptimeMs: number): string {
    const seconds = Math.floor(uptimeMs / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    if (days > 0) {
      return `${days}d ${hours % 24}h ${minutes % 60}m`;
    } else if (hours > 0) {
      return `${hours}h ${minutes % 60}m ${seconds % 60}s`;
    } else if (minutes > 0) {
      return `${minutes}m ${seconds % 60}s`;
    } else {
      return `${seconds}s`;
    }
  }
}
