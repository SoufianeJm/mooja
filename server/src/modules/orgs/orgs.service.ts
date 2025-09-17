import { Injectable, ConflictException, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { VerifyOrgDto } from './dto/verify-org.dto';
import { RegisterOrgDto } from './dto/register-org.dto';
import { MESSAGES } from '../../common/constants/app.constants';
import { HashUtil } from '../../common/utils/hash.util';

@Injectable()
export class OrgsService {
  constructor(private readonly prisma: PrismaService) {}

  async register(registerOrgDto: RegisterOrgDto) {
    // Check username availability
    const { isAvailable } = await this.checkUsernameAvailability(registerOrgDto.username);
    
    if (!isAvailable) {
      throw new ConflictException(MESSAGES.ERROR.USERNAME_TAKEN);
    }

    // Hash the password using HashUtil
    const hashedPassword = await HashUtil.hash(registerOrgDto.password);

    // Create the organization
    const org = await this.prisma.org.create({
      data: {
        name: registerOrgDto.name,
        username: registerOrgDto.username,
        password: hashedPassword,
        country: registerOrgDto.country,
        socialMediaPlatform: registerOrgDto.socialMediaPlatform,
        socialMediaHandle: registerOrgDto.socialMediaHandle,
        pictureUrl: registerOrgDto.pictureUrl,
        verificationStatus: 'pending', // Always starts as pending until invite code is used
      },
      select: {
        id: true,
        name: true,
        username: true,
        country: true,
        socialMediaPlatform: true,
        socialMediaHandle: true,
        verificationStatus: true,
        pictureUrl: true,
        createdAt: true,
      },
    });

    return {
      message: 'Organization registered successfully. Please verify with your invite code.',
      org,
    };
  }

  /**
   * Verify application code (public endpoint for pre-registration)
   */
  async verifyApplicationCode(applicationId: string, inviteCode: string) {
    // Get the organization by application ID
    const org = await this.prisma.org.findUnique({
      where: { id: applicationId },
    });

    if (!org) {
      throw new NotFoundException('Application not found');
    }

    // Check if already verified
    if (org.verificationStatus === 'verified') {
      return {
        message: 'Organization is already verified',
        verified: true,
        org: {
          id: org.id,
          name: org.name,
          username: org.username,
        },
      };
    }

    // Check if organization is in approved status
    if (org.verificationStatus !== 'approved') {
      throw new BadRequestException('Application is not approved for verification');
    }

    // Check the invite code
    const invite = await this.prisma.inviteCode.findUnique({
      where: { code: inviteCode },
    });

    if (!invite) {
      throw new BadRequestException('Invalid invite code');
    }

    // Check if invite is already used
    if (invite.isUsed) {
      throw new BadRequestException('This invite code has already been used');
    }

    // Check if invite is expired
    if (new Date() > invite.expiresAt) {
      throw new BadRequestException('This invite code has expired');
    }

    // Don't mark as verified yet - just validate the code and save it for later
    // The invite code will be marked as used only after registration is complete
    const updatedOrg = await this.prisma.org.update({
      where: { id: applicationId },
      data: {
        // Keep status as approved, not verified yet
        inviteCodeUsed: inviteCode, // Store the code for later verification
      },
    });

    return {
      message: 'Invite code validated successfully. Please create your account to complete verification.',
      validated: true, // Changed from verified to validated
      org: {
        id: updatedOrg.id,
        name: updatedOrg.name,
        username: updatedOrg.username,
        verificationStatus: updatedOrg.verificationStatus,
      },
    };
  }

  /**
   * Verify with invite code (authenticated endpoint for existing orgs)
   */
  async verifyWithInviteCode(orgId: string, inviteCode: string) {
    // Get the organization
    const org = await this.prisma.org.findUnique({
      where: { id: orgId },
    });

    if (!org) {
      throw new NotFoundException(MESSAGES.ERROR.ORG_NOT_FOUND);
    }

    // Check if already verified
    if (org.verificationStatus === 'verified') {
      return {
        message: 'Organization is already verified',
        verified: true,
      };
    }

    // Check the invite code
    const invite = await this.prisma.inviteCode.findUnique({
      where: { code: inviteCode },
    });

    if (!invite) {
      throw new BadRequestException('Invalid invite code');
    }

    // Check if invite is already used
    if (invite.isUsed) {
      throw new BadRequestException('This invite code has already been used');
    }

    // Check if invite is expired
    if (new Date() > invite.expiresAt) {
      throw new BadRequestException('This invite code has expired');
    }

    // Verify the organization and mark invite as used
    const [updatedOrg, updatedInvite] = await this.prisma.$transaction([
      this.prisma.org.update({
        where: { id: orgId },
        data: {
          verificationStatus: 'verified',
          verifiedAt: new Date(),
          inviteCodeUsed: inviteCode,
        },
      }),
      this.prisma.inviteCode.update({
        where: { code: inviteCode },
        data: {
          isUsed: true,
        },
      }),
    ]);

    return {
      message: 'Organization verified successfully',
      org: {
        id: updatedOrg.id,
        name: updatedOrg.name,
        username: updatedOrg.username,
        verificationStatus: updatedOrg.verificationStatus,
        verifiedAt: updatedOrg.verifiedAt,
      },
    };
  }

  async requestVerification(verifyOrgDto: VerifyOrgDto) {
    // Generate a candidate username from provided name
    const base = (verifyOrgDto.name || '')
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '_')
      .replace(/^_+|_+$/g, '')
      .slice(0, 30) || 'org';

    let candidate = base;
    let suffix = 0;

    // Try to find a unique username with minimal timing leak
    // Add bounded attempts to avoid long loops
    for (let i = 0; i < 20; i++) {
      const { isAvailable } = await this.checkUsernameAvailability(candidate);
      if (isAvailable) break;
      suffix++;
      candidate = `${base}_${suffix}`.slice(0, 50);
    }

    // Final check; if still not available, append a short hash-like suffix
    const { isAvailable: finalAvailable } = await this.checkUsernameAvailability(candidate);
    if (!finalAvailable) {
      const random = Math.random().toString(36).slice(2, 6);
      candidate = `${base}_${random}`.slice(0, 50);
    }

    // Create org with pending verification status
    const org = await this.prisma.org.create({
      data: {
        name: verifyOrgDto.name,
        username: candidate,
        country: verifyOrgDto.country,
        socialMediaPlatform: verifyOrgDto.socialMediaPlatform || null,
        socialMediaHandle: verifyOrgDto.socialMediaHandle || null,
        verificationStatus: 'pending',
      },
      select: {
        id: true,
        name: true,
        username: true,
        country: true,
        socialMediaPlatform: true,
        socialMediaHandle: true,
        verificationStatus: true,
        createdAt: true,
      },
    });

    return {
      message: MESSAGES.SUCCESS.VERIFICATION_REQUESTED,
      org,
    };
  }

  async findById(id: string) {
    const org = await this.prisma.org.findUnique({
      where: { id },
      select: {
        id: true,
        username: true,
        country: true,
        socialMediaPlatform: true,
        socialMediaHandle: true,
        verificationStatus: true,
        pictureUrl: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!org) {
      throw new NotFoundException(MESSAGES.ERROR.ORG_NOT_FOUND);
    }

    return org;
  }

  async findByUsername(username: string) {
    return this.prisma.org.findFirst({
      where: { 
        username: {
          equals: username,
          mode: 'insensitive'
        }
      },
    });
  }

  async findByCountry(country: string) {
    return this.prisma.org.findMany({
      where: { 
        country: {
          equals: country,
          mode: 'insensitive'
        }
      },
      select: {
        id: true,
        username: true,
        name: true,
        country: true,
        socialMediaPlatform: true,
        socialMediaHandle: true,
        verificationStatus: true,
        pictureUrl: true,
        createdAt: true,
      },
    });
  }

  /**
   * Check username availability with timing normalization
   * This helps prevent timing-based username enumeration
   */
  private async checkUsernameAvailability(username: string): Promise<{ isAvailable: boolean }> {
    const startTime = Date.now();
    
    // Check if username already exists (case insensitive)
    const existingOrg = await this.prisma.org.findFirst({
      where: { 
        username: {
          equals: username,
          mode: 'insensitive'
        }
      },
    });
    
    // Normalize timing to prevent timing attacks (minimum 50ms)
    const elapsed = Date.now() - startTime;
    const minDelay = 50;
    if (elapsed < minDelay) {
      await new Promise(resolve => setTimeout(resolve, minDelay - elapsed));
    }
    
    return { isAvailable: !existingOrg };
  }
}
