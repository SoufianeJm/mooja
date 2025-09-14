import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import { join } from 'path';
import * as fs from 'fs';
import { RequestWithContext } from './interfaces/upload.interfaces';
import { SupabaseService } from '../../common/services/supabase.service';

@Injectable()
export class UploadService implements OnModuleInit {
  private readonly logger = new Logger(UploadService.name);
  private readonly uploadsDir = join(process.cwd(), 'uploads');
  private readonly supabaseService = SupabaseService.getInstance();

  async onModuleInit() {
    // Initialize uploads directory once during module startup
    await this.ensureUploadsDirectory();
  }

  private async ensureUploadsDirectory(): Promise<void> {
    try {
      if (!fs.existsSync(this.uploadsDir)) {
        fs.mkdirSync(this.uploadsDir, { recursive: true });
        this.logger.log(`Created uploads directory: ${this.uploadsDir}`);
      }
    } catch (error: any) {
      this.logger.error(`Failed to create uploads directory: ${error.message}`, error.stack);
      throw error;
    }
  }

  getUploadsDirectory(): string {
    return this.uploadsDir;
  }

  generateFileUrl(filename: string, req: RequestWithContext): string {
    let baseUrl = process.env.BASE_URL;
    
    if (!baseUrl) {
      // Auto-detect based on request headers with better fallbacks
      const userAgent = req.headers['user-agent'] || '';
      const isFlutterApp = userAgent.includes('Dart') || userAgent.includes('Flutter');
      
      if (process.env.NODE_ENV === 'development' && isFlutterApp) {
        // Mobile development - check for iOS simulator vs Android emulator
        const isIOSSimulator = userAgent.toLowerCase().includes('ios');
        baseUrl = isIOSSimulator ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
      } else {
        // Web browser or production - use proper protocol detection
        const protocol = req.get('x-forwarded-proto') || req.protocol || (process.env.NODE_ENV === 'production' ? 'https' : 'http');
        const host = req.get('x-forwarded-host') || req.get('host') || 'localhost:3000';
        baseUrl = `${protocol}://${host}`;
      }
    }
    
    return `${baseUrl}/uploads/${filename}`;
  }

  async uploadToSupabase(file: any): Promise<string> {
    try {
      // Generate unique filename
      const timestamp = Date.now();
      const randomId = Math.random().toString(36).substring(2, 15);
      const ext = file.originalname.split('.').pop();
      const fileName = `images/${timestamp}-${randomId}.${ext}`;

      // Upload to Supabase Storage
      const fileBuffer = file.buffer;
      await this.supabaseService.uploadFile('uploads', fileName, fileBuffer, file.mimetype);

      // Return the public URL
      return this.supabaseService.getPublicUrl('uploads', fileName);
    } catch (error: any) {
      this.logger.error(`Failed to upload to Supabase: ${error.message}`, error.stack);
      throw error;
    }
  }
}
