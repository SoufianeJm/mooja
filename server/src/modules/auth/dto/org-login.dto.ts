import { IsNotEmpty, IsString } from 'class-validator';

export class OrgLoginDto {
  @IsString()
  @IsNotEmpty()
  username: string;

  @IsString()
  @IsNotEmpty()
  password: string;
}
