import { IsNotEmpty, IsString, MaxLength, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class VerifyOrgDto {
  @ApiProperty({
    description: "Organization's display name (used to generate username)",
    example: 'Climate Action NYC'
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  name: string;

  @ApiProperty({
    description: 'Country where the organization is based',
    example: 'United States'
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  country: string;

  @ApiProperty({
    description: 'Social media platform name',
    example: 'Twitter',
    required: false
  })
  @IsString()
  @IsOptional()
  @MaxLength(50)
  socialMediaPlatform?: string; // Twitter, Instagram, Facebook, etc.

  @ApiProperty({
    description: 'Social media handle or username',
    example: '@climate_action_nyc',
    required: false
  })
  @IsString()
  @IsOptional()
  @MaxLength(100)
  socialMediaHandle?: string; // Handle/username on the platform
}
