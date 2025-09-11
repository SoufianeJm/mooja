import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { plainToInstance } from 'class-transformer';
import { PrismaService } from '../../prisma/prisma.service';
import { OrgsService } from '../orgs/orgs.service';
import { OrgLoginDto } from './dto/org-login.dto';
import { RegisterOrgDto } from '../orgs/dto/register-org.dto';
import { AuthResponseDto } from './dto/auth-response.dto';
import { ActivateAccountDto } from './dto/activate-account.dto';
import { HashUtil } from '../../common/utils/hash.util';
import { MESSAGES } from '../../common/constants/app.constants';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly orgsService: OrgsService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async orgRegister(registerOrgDto: RegisterOrgDto) {
    // Register the organization
    const result = await this.orgsService.register(registerOrgDto);
    
    // Generate JWT tokens for the new organization
    const tokens = this.generateTokens({ 
      id: result.org.id, 
      username: result.org.username 
    });
    
    const response = {
      org: result.org,
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      message: result.message,
    };
    
    return plainToInstance(AuthResponseDto, response, { 
      excludeExtraneousValues: true 
    });
  }

  async orgLogin(orgLoginDto: OrgLoginDto) {
    const org = await this.orgsService.findByUsername(orgLoginDto.username);
    
    if (!org) {
      throw new UnauthorizedException(MESSAGES.ERROR.INVALID_CREDENTIALS);
    }

    // Check if org is pending, approved, or verified (allow all three to login)
    const allowedStatuses = ['pending', 'approved', 'verified'];
    if (!allowedStatuses.includes(org.verificationStatus)) {
      // Only reject if status is 'rejected' or something else unexpected
      throw new UnauthorizedException(MESSAGES.ERROR.ORG_NOT_VERIFIED);
    }

    // Check if org has password set (should be set after verification)
    if (!org.password) {
      throw new UnauthorizedException(MESSAGES.ERROR.CONTACT_SUPPORT);
    }

    const isPasswordValid = await HashUtil.compare(orgLoginDto.password, org.password);
    
    if (!isPasswordValid) {
      throw new UnauthorizedException(MESSAGES.ERROR.INVALID_CREDENTIALS);
    }

    // Create public org data (remove password field)
    const { password, ...publicOrgData } = org;
    
    // Generate both access and refresh tokens
    const tokens = this.generateTokens({ id: org.id, username: org.username });
    
    const response = {
      org: publicOrgData,
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    };
    
    return plainToInstance(AuthResponseDto, response, { 
      excludeExtraneousValues: true 
    });
  }

  async validateOrg(orgId: string) {
    const org = await this.orgsService.findById(orgId);
    
    if (!org) {
      throw new UnauthorizedException();
    }

    return org;
  }

  private generateTokens(org: { id: string; username: string }) {
    const payload = { 
      sub: org.id, 
      username: org.username,
      type: 'org',
    };
    
    // Generate access token (short-lived)
    const accessToken = this.jwtService.sign(payload, {
      expiresIn: this.configService.get('JWT_EXPIRATION', '15m'),
    });
    
    // Generate refresh token (long-lived)
    const refreshToken = this.jwtService.sign(
      { ...payload, isRefresh: true },
      {
        expiresIn: this.configService.get('JWT_REFRESH_EXPIRATION', '7d'),
        secret: this.configService.get('JWT_REFRESH_SECRET', this.configService.get('JWT_SECRET')),
      }
    );
    
    return { accessToken, refreshToken };
  }
  
  async refreshToken(refreshToken: string) {
    try {
      // Verify the refresh token with the refresh secret
      const payload = this.jwtService.verify(refreshToken, {
        secret: this.configService.get('JWT_REFRESH_SECRET', this.configService.get('JWT_SECRET')),
      });
      
      // Check if it's actually a refresh token
      if (!payload.isRefresh) {
        throw new UnauthorizedException('Invalid refresh token');
      }
      
      // Get the organization to ensure it still exists and is valid
      const org = await this.orgsService.findByUsername(payload.username);
      const allowedStatuses = ['pending', 'approved', 'verified'];
      if (!org || !allowedStatuses.includes(org.verificationStatus)) {
        throw new UnauthorizedException('Organization not found or not authorized');
      }
      
      // Generate new tokens
      const tokens = this.generateTokens({ 
        id: org.id, 
        username: org.username 
      });
      
      // Create public org data (remove password field if it exists)
      const publicOrgData = {
        id: org.id,
        username: org.username,
        country: org.country,
        socialMediaPlatform: org.socialMediaPlatform,
        socialMediaHandle: org.socialMediaHandle,
        verificationStatus: org.verificationStatus,
        pictureUrl: org.pictureUrl,
        createdAt: org.createdAt,
        updatedAt: org.updatedAt,
      };
      
      const response = {
        org: publicOrgData,
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      };
      
      return plainToInstance(AuthResponseDto, response, { 
        excludeExtraneousValues: true 
      });
    } catch (error: any) {
      if (error.name === 'TokenExpiredError') {
        throw new UnauthorizedException('Refresh token has expired');
      }
      if (error.name === 'JsonWebTokenError') {
        throw new UnauthorizedException('Invalid refresh token');
      }
      throw error;
    }
  }

  async activateAccount(orgId: string, activateAccountDto: ActivateAccountDto) {
    const { inviteCode } = activateAccountDto;

    // Get the organization
    const org = await this.prisma.org.findUnique({
      where: { id: orgId },
    });

    if (!org) {
      throw new BadRequestException('Organization not found');
    }

    // Check if already verified
    if (org.verificationStatus === 'verified') {
      return { message: 'Account is already verified' };
    }

    // Check if org is approved (has an invite code)
    if (org.verificationStatus !== 'approved') {
      throw new BadRequestException('Account is not approved for activation');
    }

    // Verify the invite code matches
    if (org.inviteCodeUsed !== inviteCode) {
      throw new BadRequestException('Invalid invite code');
    }

    // Check if invite code exists and is valid
    const inviteCodeRecord = await this.prisma.inviteCode.findUnique({
      where: { code: inviteCode },
    });

    if (!inviteCodeRecord) {
      throw new BadRequestException('Invite code not found');
    }

    // Check if code is expired
    if (new Date() > inviteCodeRecord.expiresAt) {
      throw new BadRequestException('Invite code has expired');
    }

    // Check if code is already used
    if (inviteCodeRecord.isUsed) {
      throw new BadRequestException('Invite code has already been used');
    }

    // Update organization status to verified
    const updatedOrg = await this.prisma.org.update({
      where: { id: orgId },
      data: {
        verificationStatus: 'verified',
        verifiedAt: new Date(),
        updatedAt: new Date(),
      },
    });

    // Mark invite code as used
    await this.prisma.inviteCode.update({
      where: { code: inviteCode },
      data: {
        isUsed: true,
        updatedAt: new Date(),
      },
    });

    // Remove password from response
    const { password, ...publicOrgData } = updatedOrg;

    return {
      message: 'Account successfully activated!',
      org: publicOrgData,
    };
  }
}
