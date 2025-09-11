import { Request } from 'express';

export interface UploadedFileInterface {
  fieldname: string;
  originalname: string;
  encoding: string;
  mimetype: string;
  size: number;
  filename: string;
  destination: string;
  path: string;
  buffer?: Buffer;
}

export interface RequestWithContext extends Request {
  id?: string;
  startTime?: number;
}

export interface UploadResponse {
  message: string;
  filename: string;
  url: string;
  size: number;
  mimetype: string;
}

export interface BaseUrlDetectionOptions {
  userAgent?: string;
  protocol?: string;
  host?: string;
  isFlutterApp?: boolean;
}
