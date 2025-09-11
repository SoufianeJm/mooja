import * as bcrypt from 'bcrypt';

export class HashUtil {
  static async hash(plainText: string, saltRounds: number = 10): Promise<string> {
    return bcrypt.hash(plainText, saltRounds);
  }

  static async compare(plainText: string, hash: string): Promise<boolean> {
    return bcrypt.compare(plainText, hash);
  }
}
