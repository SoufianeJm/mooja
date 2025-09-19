import { plainToInstance, Transform } from 'class-transformer';
import { 
  IsString, 
  IsNumber, 
  IsOptional, 
  IsEnum, 
  Min, 
  Max, 
  validateSync,
  IsNotEmpty,
  MinLength
} from 'class-validator';

enum NodeEnvironment {
  DEVELOPMENT = 'development',
  PRODUCTION = 'production',
  TEST = 'test',
}

export class EnvironmentVariables {
  // Database
  @IsString()
  @IsNotEmpty()
  DATABASE_URL: string;

  @IsOptional()
  @IsString()
  DIRECT_URL?: string;

  // JWT Authentication
  @IsString()
  @IsNotEmpty()
  @MinLength(32, { message: 'JWT_SECRET must be at least 32 characters long' })
  JWT_SECRET: string;

  @IsOptional()
  @IsString()
  JWT_EXPIRATION?: string = '30d';

  // Server Configuration
  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
  @Min(1)
  @Max(65535)
  PORT?: number = 3000;

  @IsOptional()
  @IsEnum(NodeEnvironment)
  NODE_ENV?: NodeEnvironment = NodeEnvironment.DEVELOPMENT;

  // Security - CORS removed for mobile-only app

  // Rate Limiting (Optional - will be disabled if not provided)
  @IsOptional()
  @Transform(({ value }) => value ? parseInt(value, 10) : undefined)
  @IsNumber()
  @Min(60000) // Minimum 1 minute
  RATE_LIMIT_WINDOW_MS?: number;

  @IsOptional()
  @Transform(({ value }) => value ? parseInt(value, 10) : undefined)
  @IsNumber()
  @Min(1)
  @Max(1000)
  RATE_LIMIT_MAX_REQUESTS?: number;
}

export function validateEnvironment(config: Record<string, unknown>) {
  const validatedConfig = plainToInstance(EnvironmentVariables, config, {
    enableImplicitConversion: true,
  });

  const errors = validateSync(validatedConfig, {
    skipMissingProperties: false,
  });

  if (errors.length > 0) {
    const errorMessages = errors
      .map(error => 
        Object.values(error.constraints || {}).join(', ')
      )
      .join('; ');
    
    throw new Error(`Environment validation failed: ${errorMessages}`);
  }

  return validatedConfig;
}

/**
 * Additional runtime validation for environment-specific requirements
 */
export function validateProductionEnvironment(env: EnvironmentVariables) {
  if (env.NODE_ENV === NodeEnvironment.PRODUCTION) {
    // Note: We don't import Logger here to avoid circular dependencies
    // These warnings will be logged during module initialization
    if (!env.DATABASE_URL.includes('sslmode=require')) {
      // Use console.warn in initialization - this is acceptable for startup warnings
      console.warn('⚠️  PRODUCTION WARNING: Database should use SSL (add sslmode=require to DATABASE_URL)');
    }

    if (env.JWT_SECRET.length < 64) {
      console.warn('⚠️  PRODUCTION WARNING: JWT_SECRET should be at least 64 characters long');
    }

    // Check for default/weak values
    const weakSecrets = [
      'your_jwt_secret_here_change_in_production_minimum_32_chars',
      'change_me',
      'secret',
      'password'
    ];

    if (weakSecrets.some(weak => env.JWT_SECRET.includes(weak))) {
      throw new Error('Production JWT_SECRET contains default/weak values. Please use a secure random string.');
    }
  }
}
