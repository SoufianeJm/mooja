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
    example: 'SecurePass123!',
    minLength: 8
  })
  @IsStrongPassword({
    minLength: 8,
    minLowercase: 1,
    minUppercase: 1,
    minNumbers: 1,
    minSymbols: 1,
  }, {
    message: 'Password must be at least 8 characters with uppercase, lowercase, number and symbol'
  })
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
