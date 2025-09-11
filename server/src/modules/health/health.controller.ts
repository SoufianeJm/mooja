import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { HealthService } from './health.service';
import { Public } from '../../common/decorators/public.decorator';

@ApiTags('health')
@Controller('health')
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Public()
  @Get()
  @ApiOperation({ summary: 'Get application health status' })
  @ApiResponse({ 
    status: 200, 
    description: 'Health check successful',
    schema: {
      example: {
        status: 'ok',
        info: {
          database: { status: 'up', responseTime: '15ms' },
          memory: { status: 'ok', heapUsed: '45.2 MB', heapTotal: '89.1 MB' },
          uptime: { status: 'ok', uptime: '2h 45m 30s' }
        },
        error: {},
        details: {
          database: { status: 'up', responseTime: '15ms' },
          memory: { status: 'ok', heapUsed: '45.2 MB', heapTotal: '89.1 MB' },
          uptime: { status: 'ok', uptime: '2h 45m 30s' }
        }
      }
    }
  })
  @ApiResponse({ 
    status: 503, 
    description: 'Health check failed - service unhealthy'
  })
  async check() {
    return this.healthService.check();
  }

  @Public()
  @Get('ready')
  @ApiOperation({ summary: 'Check if application is ready to serve requests' })
  @ApiResponse({ 
    status: 200, 
    description: 'Application is ready',
    schema: {
      example: {
        status: 'ready',
        checks: {
          database: true,
          environment: true,
          dependencies: true
        },
        timestamp: '2025-08-30T07:30:00Z'
      }
    }
  })
  @ApiResponse({ status: 503, description: 'Application not ready' })
  async readiness() {
    return this.healthService.readinessCheck();
  }

  @Public()
  @Get('live')
  @ApiOperation({ summary: 'Check if application is alive (liveness probe)' })
  @ApiResponse({ 
    status: 200, 
    description: 'Application is alive',
    schema: {
      example: {
        status: 'alive',
        timestamp: '2025-08-30T07:30:00Z',
        version: '1.0.0'
      }
    }
  })
  async liveness() {
    return this.healthService.livenessCheck();
  }
}
