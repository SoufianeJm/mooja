import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import helmet from 'helmet';
import * as express from 'express';
import { join } from 'path';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const logger = new Logger('Bootstrap');
  const port = process.env.PORT || 3000;
  
  // Security headers with Helmet
  app.use(helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'"],
        imgSrc: ["'self'", 'data:', 'https:', 'http://localhost:*', 'http://127.0.0.1:*'],
        connectSrc: ["'self'", 'http://localhost:*', 'http://127.0.0.1:*'],
      },
    },
    crossOriginEmbedderPolicy: false, // Required for API usage
    crossOriginResourcePolicy: { policy: 'cross-origin' }, // Allow cross-origin resource loading
  }));
  
  // Enable CORS with proper configuration
  const allowedOrigins = process.env.ALLOWED_ORIGINS 
    ? process.env.ALLOWED_ORIGINS.split(',').map(origin => origin.trim())
    : ['http://localhost:3000']; // Default for development

  // More permissive CORS for development
  const corsOptions = {
    origin: process.env.NODE_ENV === 'development' 
      ? (origin: any, callback: any) => {
          // Allow requests with no origin (like mobile apps, file://, or Postman)
          if (!origin) return callback(null, true);
          // Check if origin is in allowed list
          if (allowedOrigins.includes(origin)) return callback(null, true);
          // Allow localhost with any port in development
          if (origin.match(/^https?:\/\/(localhost|127\.0\.0\.1|\[?::1\]?):\d+$/)) {
            return callback(null, true);
          }
          return callback(new Error('Not allowed by CORS'));
        }
      : allowedOrigins,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: false, // Changed to false for file:// protocol compatibility
  };

  app.enableCors(corsOptions);
  
  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );
  
  // Serve static files for uploads with security headers (before global prefix)
  app.use('/uploads', express.static(join(process.cwd(), 'uploads'), {
    setHeaders: (res, path, stat) => {
      // Prevent MIME type sniffing attacks
      res.setHeader('X-Content-Type-Options', 'nosniff');
      // Sandbox content to prevent XSS attacks
      res.setHeader('Content-Security-Policy', "default-src 'none'; style-src 'unsafe-inline'; sandbox");
      // Force download for non-image files to prevent execution
      const ext = require('path').extname(path).toLowerCase();
      if (!['.jpg', '.jpeg', '.png', '.gif', '.webp'].includes(ext)) {
        res.setHeader('Content-Disposition', 'attachment');
      }
    }
  }));
  
  // Global prefix
  app.setGlobalPrefix('api');
  
  // Swagger API documentation
  if (process.env.NODE_ENV !== 'production') {
    const config = new DocumentBuilder()
      .setTitle('Mooja API')
      .setDescription('The Mooja protest organization app API documentation')
      .setVersion('1.0')
      .addTag('protests', 'Public protest feed and details')
      .addTag('orgs', 'Organization verification and management')
      .addTag('auth', 'Organization authentication')
      .addBearerAuth(
        {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          name: 'JWT',
          description: 'Enter JWT token',
          in: 'header',
        },
        'JWT-auth',
      )
      .build();
    
    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api/docs', app, document, {
      customSiteTitle: 'Mooja API Documentation',
    });
    
    logger.log(`📚 API Documentation available at: http://localhost:${port}/api/docs`);
  }
  
  await app.listen(port);
  logger.log(`🚀 Application is running on: http://localhost:${port}`);
  logger.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
  logger.log(`🔗 CORS Origins: ${process.env.ALLOWED_ORIGINS || 'localhost only'}`);
  logger.log('✅ Mooja API startup complete');
  
  // Graceful shutdown handling
  const signals = ['SIGTERM', 'SIGINT'];
  signals.forEach(signal => {
    process.on(signal, async () => {
      logger.log(`${signal} received, shutting down gracefully...`);
      await app.close();
      logger.log('Application closed successfully');
      process.exit(0);
    });
  });
}
bootstrap();
