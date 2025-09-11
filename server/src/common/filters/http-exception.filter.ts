import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';

interface RequestWithId extends Request {
  id?: string;
}

@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: HttpException, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const request = ctx.getRequest<RequestWithId>();
    const response = ctx.getResponse<Response>();
    const status = exception.getStatus();
    const exceptionResponse = exception.getResponse();

    // Get request ID for correlation
    const requestId = request.id || 'unknown';
    const method = request.method;
    const url = request.url;

    const error =
      typeof exceptionResponse === 'string'
        ? { message: exceptionResponse }
        : (exceptionResponse as object);

    // Log the error with context
    this.logger.error(
      `[${requestId}] ${method} ${url} - ${status} - ${exception.message}`,
      exception.stack
    );

    const errorResponse = {
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: url,
      method,
      requestId,
      ...error,
    };

    response.status(status).json(errorResponse);
  }
}
