import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD, APP_FILTER, APP_INTERCEPTOR } from '@nestjs/core';
import { AuthModule } from './modules/auth/auth.module';
import { OrgsModule } from './modules/orgs/orgs.module';
import { ProtestsModule } from './modules/protests/protests.module';
import { HealthModule } from './modules/health/health.module';
import { UploadModule } from './modules/upload/upload.module';
import { PrismaModule } from './prisma/prisma.module';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { RequestContextInterceptor } from './common/interceptors/request-context.interceptor';
import { validateEnvironment, validateProductionEnvironment } from './config/env.validation';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
      validate: (config) => {
        const validated = validateEnvironment(config);
        validateProductionEnvironment(validated);
        return validated;
      },
    }),
    // Conditionally enable rate limiting only if environment variables are provided
    ...(process.env.RATE_LIMIT_WINDOW_MS && process.env.RATE_LIMIT_MAX_REQUESTS ? [
      ThrottlerModule.forRootAsync({
        imports: [ConfigModule],
        useFactory: (configService: ConfigService) => ({
          throttlers: [
            {
              name: 'default',
              ttl: parseInt(configService.get('RATE_LIMIT_WINDOW_MS'), 10),
              limit: parseInt(configService.get('RATE_LIMIT_MAX_REQUESTS'), 10),
            },
          ],
        }),
        inject: [ConfigService],
      })
    ] : []),
    PrismaModule,
    OrgsModule,
    AuthModule,
    ProtestsModule,
    HealthModule,
    UploadModule,
  ],
  controllers: [],
  providers: [
    {
      provide: APP_INTERCEPTOR,
      useClass: RequestContextInterceptor,
    },
    // Conditionally enable ThrottlerGuard only if rate limiting is configured
    ...(process.env.RATE_LIMIT_WINDOW_MS && process.env.RATE_LIMIT_MAX_REQUESTS ? [
      {
        provide: APP_GUARD,
        useClass: ThrottlerGuard,
      }
    ] : []),
    {
      provide: APP_FILTER,
      useClass: HttpExceptionFilter,
    },
  ],
})
export class AppModule {}
