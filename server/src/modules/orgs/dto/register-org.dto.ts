import { IsString, IsNotEmpty, MinLength, IsOptional, IsUrl, IsStrongPassword } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class RegisterOrgDto {
  @ApiProperty({ description: 'Organization name' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ description: 'Username for login' })
  @IsString()
  @IsNotEmpty()
  @MinLength(3)
  username: string;

  @ApiProperty({ 
    description: 'Password for login',
    example: 'password123',
    minLength: 8
  })
  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters' })
  password: string;

  @ApiPropertyOptional({ description: 'Country of the organization' })
  @IsOptional()
  @IsString()
  country?: string;

  @ApiPropertyOptional({ description: 'Social media platform' })
  @IsOptional()
  @IsString()
  socialMediaPlatform?: string;

  @ApiPropertyOptional({ description: 'Social media handle' })
  @IsOptional()
  @IsString()
  socialMediaHandle?: string;

  @ApiPropertyOptional({ description: 'Profile picture URL' })
  @IsOptional()
  @IsString()
  pictureUrl?: string;
}
