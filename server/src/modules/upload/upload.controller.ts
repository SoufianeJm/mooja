import {
  Controller,
  Post,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
  Req,
  ParseFilePipe,
  MaxFileSizeValidator,
  FileTypeValidator,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiResponse, ApiConsumes, ApiBody } from '@nestjs/swagger';
import { diskStorage } from 'multer';
import { extname } from 'path';
import * as crypto from 'crypto';
import { UploadService } from './upload.service';
import { UploadedFileInterface, RequestWithContext, UploadResponse } from './interfaces/upload.interfaces';
import { APP_CONSTANTS } from '../../common/constants/app.constants';

@ApiTags('upload')
@Controller('upload')
export class UploadController {
  constructor(private readonly uploadService: UploadService) {}

  @Post('image')
  @ApiOperation({ summary: 'Upload an image file' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    description: 'Image file to upload',
    type: 'multipart/form-data',
    schema: {
      type: 'object',
      properties: {
        file: {
          type: 'string',
          format: 'binary',
        },
      },
    },
  })
  @ApiResponse({ 
    status: 201, 
    description: 'Image uploaded successfully',
    schema: {
      type: 'object',
      properties: {
        message: { type: 'string' },
        filename: { type: 'string' },
        url: { type: 'string' },
        size: { type: 'number' },
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid file type or size' })
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: APP_CONSTANTS.UPLOAD.UPLOAD_DIRECTORY,
        filename: (req: any, file: any, callback: any) => {
          // Generate cryptographically secure unique filename
          const uniqueId = crypto.randomUUID();
          const timestamp = Date.now();
          const ext = extname(file.originalname);
          const filename = `${file.fieldname}${APP_CONSTANTS.UPLOAD.FILENAME_SEPARATOR}${timestamp}${APP_CONSTANTS.UPLOAD.FILENAME_SEPARATOR}${uniqueId}${ext}`;
          callback(null, filename);
        },
      }),
      limits: {
        fileSize: APP_CONSTANTS.UPLOAD.MAX_FILE_SIZE_BYTES,
      },
    })
  )
  async uploadImage(
    @UploadedFile(
      new ParseFilePipe({
        validators: [
          new MaxFileSizeValidator({ maxSize: APP_CONSTANTS.UPLOAD.MAX_FILE_SIZE_BYTES }),
          new FileTypeValidator({ fileType: /^image\/(jpeg|jpg|png|gif|webp)$/ }),
        ],
        errorHttpStatusCode: 400,
      }),
    ) file: UploadedFileInterface,
    @Req() req: RequestWithContext,
  ): Promise<UploadResponse> {
    // File validation is now handled by ParseFilePipe validators
    if (!file) {
      throw new BadRequestException('No file uploaded');
    }

    try {
      // Upload to Supabase Storage
      const fileUrl = await this.uploadService.uploadToSupabase(file);
      
      // Extract filename from URL for response
      const fileName = fileUrl.split('/').pop() || file.filename;

      return {
        message: 'Image uploaded successfully to Supabase Storage',
        filename: fileName,
        url: fileUrl,
        size: file.size,
        mimetype: file.mimetype,
      };
    } catch (error: any) {
      throw new BadRequestException(`Upload failed: ${error.message}`);
    }
  }
}
