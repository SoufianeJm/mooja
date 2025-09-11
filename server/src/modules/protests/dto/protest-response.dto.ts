import { Exclude, Expose, Type } from 'class-transformer';

class OrganizerDto {
  @Expose()
  id: string;

  @Expose()
  username: string;

  @Expose()
  name?: string;

  @Expose()
  pictureUrl?: string;

  @Expose()
  country?: string;

  @Expose()
  verificationStatus?: string;

  @Expose()
  socialMediaPlatform?: string;

  @Expose()
  socialMediaHandle?: string;
}

export class ProtestResponseDto {
  @Expose()
  id: string;

  @Expose()
  title: string;

  @Expose()
  dateTime: Date;

  @Expose()
  country?: string;

  @Expose()
  city?: string;

  @Expose()
  location: string;

  @Expose()
  pictureUrl?: string;

  @Expose()
  description?: string;

  @Expose()
  organizerId: string;

  @Expose()
  @Type(() => OrganizerDto)
  organizer: OrganizerDto;

  @Expose()
  createdAt: Date;

  @Expose()
  updatedAt: Date;

  constructor(partial: Partial<ProtestResponseDto>) {
    Object.assign(this, partial);
  }
}

export class CreateProtestResponseDto {
  @Expose()
  message: string;

  @Expose()
  @Type(() => ProtestResponseDto)
  protest: ProtestResponseDto;

  constructor(partial: Partial<CreateProtestResponseDto>) {
    Object.assign(this, partial);
  }
}
