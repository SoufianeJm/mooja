import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty } from 'class-validator';

export class VerifyCodeDto {
  @ApiProperty({
    description: 'Application ID of the organization',
    example: 'cmfo85nsl0000ujv8d561qt9u',
  })
  @IsString()
  @IsNotEmpty()
  applicationId: string;

  @ApiProperty({
    description: 'Invite code received for verification',
    example: 'INVITE123',
  })
  @IsString()
  @IsNotEmpty()
  inviteCode: string;
}