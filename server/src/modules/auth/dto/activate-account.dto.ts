import { IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ActivateAccountDto {
  @ApiProperty({
    description: 'The invite code to activate the account',
    example: 'MOOJA-A1B2-C3D4',
  })
  @IsNotEmpty()
  @IsString()
  inviteCode: string;
}
