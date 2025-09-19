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
    // Check if org exists and has validated invite code
    const existingOrg = await this.orgsService.findByUsername(registerOrgDto.username);
    
    if (existingOrg) {
      // Check if org has a validated invite code but no password yet
      if (existingOrg.inviteCodeUsed && !existingOrg.password) {
        // Complete the registration and mark as verified
        const hashedPassword = await HashUtil.hash(registerOrgDto.password);
        
        // Update org with password and mark as verified in transaction
        const [updatedOrg, updatedInvite] = await this.prisma.$transaction([
          this.prisma.org.update({
            where: { id: existingOrg.id },
            data: {
              password: hashedPassword,
              verificationStatus: 'verified',
              verifiedAt: new Date(),
              // Update other fields from registration
              name: registerOrgDto.name || existingOrg.name,
              country: registerOrgDto.country || existingOrg.country,
              socialMediaPlatform: registerOrgDto.socialMediaPlatform || existingOrg.socialMediaPlatform,
              socialMediaHandle: registerOrgDto.socialMediaHandle || existingOrg.socialMediaHandle,
            },
          }),
          // Mark the invite code as used
          this.prisma.inviteCode.update({
            where: { code: existingOrg.inviteCodeUsed },
            data: { isUsed: true },
          }),
        ]);
        
        // Generate JWT tokens
        const tokens = this.generateTokens({ 
          id: updatedOrg.id, 
          username: updatedOrg.username 
        });
        
        // Remove password from response
        const { password, ...publicOrgData } = updatedOrg;
        
        const response = {
          org: publicOrgData,
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
          message: 'Organization registered and verified successfully',
        };
        
        return plainToInstance(AuthResponseDto, response, { 
          excludeExtraneousValues: true 
        });
      } else {
        throw new BadRequestException('Username already taken');
      }
    }
    
    // If no existing org, proceed with normal registration (without verification)
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

  async orgRegisterByApplicationId(applicationId: string, username: string, password: string) {
    if (!applicationId || !username || !password) {
      throw new BadRequestException('applicationId, username and password are required');
    }

    // Get the pending/approved org by application id
    const org = await this.prisma.org.findUnique({ where: { id: applicationId } });
    if (!org) {
      throw new BadRequestException('Application not found');
    }

    // Ensure invite code was validated in the prior step
    if (!org.inviteCodeUsed) {
      // Allow pending flow too: set password and keep status (optional), but safer to require approved
      // For now require an invite code validated to avoid abuse
      throw new BadRequestException('Application not approved or invite code not validated');
    }

    // Ensure username availability (case insensitive)
    const existingWithUsername = await this.orgsService.findByUsername(username);
    if (existingWithUsername && existingWithUsername.id !== org.id) {
      throw new BadRequestException('Username already taken');
    }

    const hashedPassword = await HashUtil.hash(password);

    // Complete registration and verification in a transaction
    const [updatedOrg] = await this.prisma.$transaction([
      this.prisma.org.update({
        where: { id: applicationId },
        data: {
          username,
          password: hashedPassword,
          verificationStatus: 'verified',
          verifiedAt: new Date(),
        },
      }),
      // Mark invite code as used (idempotent if already used)
      this.prisma.inviteCode.updateMany({
        where: { code: org.inviteCodeUsed!, isUsed: false },
        data: { isUsed: true },
      }),
    ]);

    // Generate JWT tokens
    const tokens = this.generateTokens({ id: updatedOrg.id, username: updatedOrg.username });

    const { password: _, ...publicOrgData } = updatedOrg as any;

    const response = {
      org: publicOrgData,
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      message: 'Organization registered and verified successfully',
    };

    return plainToInstance(AuthResponseDto, response, { excludeExtraneousValues: true });
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
