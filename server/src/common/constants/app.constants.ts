/**
 * Application-wide constants
 * Centralizes magic numbers and hardcoded values for better maintainability
 */

export const APP_CONSTANTS = {
  // Pagination
  PAGINATION: {
    DEFAULT_LIMIT: 10,
    MAX_LIMIT: 20,
    MIN_LIMIT: 1,
  },

  // Password and Security
  SECURITY: {
    BCRYPT_SALT_ROUNDS: 10,
    MIN_PASSWORD_LENGTH: 16,
    MIN_JWT_SECRET_LENGTH: 32,
    RECOMMENDED_JWT_SECRET_LENGTH: 64,
  },

  // Rate Limiting (Optional - only used if environment variables are provided)
  RATE_LIMIT: {
    MIN_WINDOW_MS: 60000, // 1 minute
    MAX_REQUESTS_LIMIT: 1000,
  },

  // Server Configuration
  SERVER: {
    DEFAULT_PORT: 3000,
    MIN_PORT: 1,
    MAX_PORT: 65535,
  },

  // Database
  DATABASE: {
    CONNECTION_POOL: {
      TIMEOUT: 10,
      CONNECTION_LIMIT_DEV: 10,
      CONNECTION_LIMIT_PROD: 20,
    },
  },

  // HTTP
  HTTP: {
    USER_AGENT_MAX_LENGTH: 100,
  },

  // Time
  TIME: {
    ONE_DAY_MS: 24 * 60 * 60 * 1000,
    ONE_WEEK_MS: 7 * 24 * 60 * 60 * 1000,
    ONE_MONTH_MS: 30 * 24 * 60 * 60 * 1000,
  },

  // File Upload
  UPLOAD: {
    MAX_FILE_SIZE_BYTES: 5 * 1024 * 1024, // 5MB
    MAX_FILE_SIZE_MB: 5,
    ALLOWED_IMAGE_TYPES: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'],
    UPLOAD_DIRECTORY: './uploads',
    FILENAME_SEPARATOR: '-',
  },

  // Default Values
  DEFAULTS: {
    JWT_EXPIRATION: '30d',
    NODE_ENV: 'development',
  },

  // Validation
  VALIDATION: {
    CUID_LENGTH: 25, // Standard CUID length
  },
} as const;

/**
 * Password generation constants
 */
export const PASSWORD_GENERATION = {
  LENGTH: 16,
  CHARSET: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*',
  CATEGORIES: {
    LOWERCASE: 'abcdefghijklmnopqrstuvwxyz',
    UPPERCASE: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    NUMBERS: '0123456789',
    SYMBOLS: '!@#$%^&*',
  },
} as const;

/**
 * Weak/default values that should never be used in production
 */
export const WEAK_SECRETS = [
  'your_jwt_secret_here_change_in_production_minimum_32_chars',
  'change_me',
  'secret',
  'password',
  'test',
  '123456',
] as const;

/**
 * API Response Messages
 */
export const MESSAGES = {
  SUCCESS: {
    PROTEST_CREATED: 'Protest created successfully',
    ORG_APPROVED: 'Organization approved successfully',
    ORG_REJECTED: 'Organization rejected',
    ORG_CREATED: 'Organization created successfully',
    ORG_UPDATED: 'Organization updated successfully',
    ORG_DELETED: 'Organization deleted successfully',
    PASSWORD_UPDATED: 'Password updated successfully',
    VERIFICATION_REQUESTED: 'Verification request submitted. You will receive credentials once verified.',
  },
  
  ERROR: {
    INVALID_CREDENTIALS: 'Invalid credentials',
    ORG_NOT_VERIFIED: 'Organization not yet verified',
    CONTACT_SUPPORT: 'Please contact support to set up your credentials',
    USERNAME_TAKEN: 'Username is already taken. Please choose a different username.',
    ORG_NOT_FOUND: 'Organization not found',
    PROTEST_NOT_FOUND: 'Protest not found',
    ALREADY_VERIFIED: 'Organization is already verified',
    CANNOT_DELETE_WITH_PROTESTS: 'Cannot delete organization with protests. Please delete all protests first.',
    INVALID_TOKEN_TYPE: 'Invalid token type',
    JWT_SECRET_REQUIRED: 'JWT_SECRET environment variable is required but not found',
  },
  
  WARNING: {
    PRODUCTION_SSL: 'Production database should use SSL (add sslmode=require to DATABASE_URL)',
    SHORT_JWT_SECRET: 'Production JWT_SECRET should be at least 64 characters long',
  },
} as const;
