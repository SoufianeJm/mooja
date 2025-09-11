import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap, catchError } from 'rxjs/operators';
import { Request, Response } from 'express';
import * as crypto from 'crypto';

interface RequestWithId extends Request {
  id?: string;
  startTime?: number;
}

@Injectable()
export class RequestContextInterceptor implements NestInterceptor {
  private readonly logger = new Logger(RequestContextInterceptor.name);

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest<RequestWithId>();
    const response = context.switchToHttp().getResponse<Response>();
    
    // Generate unique request ID
    const requestId = crypto.randomUUID();
    const startTime = Date.now();
    
    // Add request context
    request.id = requestId;
    request.startTime = startTime;
    
    // Add request ID to response headers
    response.setHeader('X-Request-Id', requestId);
    
    const { method, url, headers } = request;
    const userAgent = headers['user-agent'] || 'unknown';
    const ip = request.ip || request.connection.remoteAddress || 'unknown';
    
    // Log incoming request
    this.logger.log(
      `[${requestId}] ${method} ${url} - IP: ${ip} - User-Agent: ${userAgent.substring(0, 100)}`
    );

    return next.handle().pipe(
      tap(() => {
        const responseTime = Date.now() - startTime;
        const statusCode = response.statusCode;
        
        this.logger.log(
          `[${requestId}] ${method} ${url} - ${statusCode} - ${responseTime}ms`
        );
      }),
      catchError((error) => {
        const responseTime = Date.now() - startTime;
        const statusCode = error.status || 500;
        
        this.logger.error(
          `[${requestId}] ${method} ${url} - ${statusCode} - ${responseTime}ms - Error: ${error.message}`,
          error.stack
        );
        
        // Re-throw the error so it can be handled by the exception filter
        throw error;
      }),
    );
  }
}
