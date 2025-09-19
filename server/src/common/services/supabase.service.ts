import { createClient } from '@supabase/supabase-js';

export class SupabaseService {
  private static instance: SupabaseService;
  private supabase;

  private constructor() {
    const supabaseUrl = process.env.SUPABASE_URL;
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error('Missing Supabase environment variables');
    }

    this.supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });
  }

  static getInstance(): SupabaseService {
    if (!SupabaseService.instance) {
      SupabaseService.instance = new SupabaseService();
    }
    return SupabaseService.instance;
  }

  getClient() {
    return this.supabase;
  }

  async uploadFile(bucketName: string, fileName: string, file: Buffer, contentType: string) {
    const { data, error } = await this.supabase.storage
      .from(bucketName)
      .upload(fileName, file, {
        contentType,
        upsert: false,
      });

    if (error) {
      throw new Error(`Failed to upload file: ${error.message}`);
    }

    return data;
  }

  getPublicUrl(bucketName: string, fileName: string): string {
    const { data } = this.supabase.storage
      .from(bucketName)
      .getPublicUrl(fileName);

    return data.publicUrl;
  }

  async deleteFile(bucketName: string, fileName: string) {
    const { error } = await this.supabase.storage
      .from(bucketName)
      .remove([fileName]);

    if (error) {
      throw new Error(`Failed to delete file: ${error.message}`);
    }
  }
}
