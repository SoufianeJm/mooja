import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { AuthService } from '../auth.service';
import { MESSAGES } from '../../../common/constants/app.constants';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private readonly configService: ConfigService,
    private readonly authService: AuthService,
  ) {
    const jwtSecret = configService.get('JWT_SECRET');
    
    if (!jwtSecret) {
      throw new Error(MESSAGES.ERROR.JWT_SECRET_REQUIRED);
    }
    
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: jwtSecret,
    });
  }

  async validate(payload: { sub: string; username: string; type: string }) {
    // Only validate org tokens
    if (payload.type !== 'org') {
      throw new UnauthorizedException(MESSAGES.ERROR.INVALID_TOKEN_TYPE);
    }

    const org = await this.authService.validateOrg(payload.sub);
    
    if (!org) {
      throw new UnauthorizedException(MESSAGES.ERROR.ORG_NOT_FOUND);
    }
    
    return org;
  }
}
