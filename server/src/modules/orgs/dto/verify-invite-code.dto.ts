import { IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class VerifyInviteCodeDto {
  @ApiProperty({
    description: 'The invite code to verify the organization',
    example: 'MOOJA-2024-DEMO'
  })
  @IsString()
  @IsNotEmpty()
  inviteCode: string;
}
