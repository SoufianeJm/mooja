import { IsNotEmpty, IsString, IsDateString, MaxLength, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateProtestDto {
  @ApiProperty({
    description: 'Title of the protest',
    example: 'Climate Action March',
    maxLength: 200
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  title: string;

  @ApiProperty({
    description: 'Date and time of the protest (ISO 8601)',
    example: '2024-12-25T10:00:00Z'
  })
  @IsDateString()
  @IsNotEmpty()
  dateTime: string; // ISO 8601 date-time string

  @ApiProperty({
    description: 'Country where the protest is happening',
    example: 'United States',
    maxLength: 100
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  country: string;

  @ApiProperty({
    description: 'City where the protest is happening',
    example: 'New York',
    maxLength: 100
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  city: string;

  @ApiProperty({
    description: 'Street address or specific location of the protest',
    example: 'City Hall, 123 Main Street',
    maxLength: 500
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(500)
  location: string;

  @ApiProperty({
    description: 'Picture URL for the protest event',
    example: 'https://example.com/uploads/protest_banner.jpg',
    required: false
  })
  @IsOptional()
  @IsString()
  @MaxLength(500, { message: 'Picture URL must not exceed 500 characters' })
  pictureUrl?: string;

  @ApiProperty({
    description: 'Description of the protest',
    example: 'Join us for urgent climate action and demand immediate policy changes.',
    required: false
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000, { message: 'Description must not exceed 1000 characters' })
  description?: string;
}
