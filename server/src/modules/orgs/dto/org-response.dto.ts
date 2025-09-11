import { Exclude, Expose } from 'class-transformer';

export class OrgResponseDto {
  @Expose()
  id: string;

  @Expose()
  username: string;

  @Expose()
  country: string;

  @Expose()
  socialMediaPlatform?: string;

  @Expose()
  socialMediaHandle?: string;

  @Expose()
  verificationStatus: string;

  @Exclude()
  password: string;

  @Expose()
  createdAt: Date;

  constructor(partial: Partial<OrgResponseDto>) {
    Object.assign(this, partial);
  }
}

export class VerificationRequestResponseDto {
  @Expose()
  message: string;

  @Expose()
  username: string;

  @Expose()
  status: string;

  constructor(partial: Partial<VerificationRequestResponseDto>) {
    Object.assign(this, partial);
  }
}
