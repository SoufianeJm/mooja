import { registerAs } from '@nestjs/config';

export default registerAs('auth', () => {
  const jwtSecret = process.env.JWT_SECRET;
  
  // Validate JWT secret in production
  if (process.env.NODE_ENV === 'production' && (!jwtSecret || jwtSecret.length < 32)) {
    throw new Error('JWT_SECRET must be at least 32 characters long in production');
  }
  
  return {
    jwt: {
      secret: jwtSecret || 'default_secret_for_development_only',
      expiresIn: process.env.JWT_EXPIRATION || '7d',
    },
    bcrypt: {
      saltRounds: 10,
    },
  };
});
