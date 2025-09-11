import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  
  /**
   * Build connection string with proper pooling parameters
   */
  private static buildConnectionString(): string {
    const baseUrl = process.env.DATABASE_URL!;
    
    // Connection pool parameters optimized for production
    const poolParams = new URLSearchParams({
      // Connection pool settings
      'connection_limit': '20',        // Max 20 connections
      'pool_timeout': '20',            // 20 second pool timeout
      'connect_timeout': '10',         // 10 second connect timeout
      'socket_timeout': '30',          // 30 second socket timeout
      
      // Performance optimizations
      'pgbouncer': 'true',            // Enable pgbouncer if using Supabase
      'prepared_statements': 'false',  // Disable for pgbouncer compatibility
      
      // SSL and connection management
      'sslmode': process.env.NODE_ENV === 'production' ? 'require' : 'prefer',
    });

    // Parse existing URL to preserve existing parameters
    const url = new URL(baseUrl);
    
    // Add our pool parameters to existing search params
    poolParams.forEach((value, key) => {
      if (!url.searchParams.has(key)) {
        url.searchParams.set(key, value);
      }
    });

    return url.toString();
  }

  constructor() {
    const isProduction = process.env.NODE_ENV === 'production';
    const connectionString = PrismaService.buildConnectionString();
    
    super({
      log: process.env.NODE_ENV === 'development' 
        ? ['query', 'warn', 'error'] // Reduced logging for performance
        : ['error'],
      datasources: {
        db: {
          url: connectionString,
        },
      },
      // Optimized connection pool and transaction settings
      transactionOptions: {
        timeout: 5000,    // 5 second timeout (reduced from 20)
        maxWait: 2000,    // 2 second max wait (reduced from 5)
        isolationLevel: 'ReadCommitted', // Better performance for read-heavy workload
      },
    });
  }

  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
