import { Exclude, Expose, Type } from 'class-transformer';

class OrgDto {
  @Expose()
  id: string;

  @Expose()
  username: string;

  @Expose()
  country: string;

  @Expose()
  socialMediaPlatform: string;

  @Expose()
  socialMediaHandle: string;

  @Expose()
  verificationStatus: string;

  @Expose()
  pictureUrl: string;

  @Expose()
  createdAt: Date;

  @Expose()
  updatedAt: Date;

  @Exclude()
  password: string;
}

export class AuthResponseDto {
  @Expose()
  @Type(() => OrgDto)
  org: OrgDto;

  @Expose()
  accessToken: string;

  @Expose()
  refreshToken?: string;

  @Expose()
  message?: string;

  constructor(partial: Partial<AuthResponseDto>) {
    Object.assign(this, partial);
  }
}
