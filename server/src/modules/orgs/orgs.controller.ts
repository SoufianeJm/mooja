import { Controller, Post, Body, Patch, Request, UseGuards, Get, Query } from '@nestjs/common';
import { Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { OrgsService } from './orgs.service';
import { VerifyOrgDto } from './dto/verify-org.dto';
import { RegisterOrgDto } from './dto/register-org.dto';
import { VerifyInviteCodeDto } from './dto/verify-invite-code.dto';
import { VerifyCodeDto } from './dto/verify-code.dto';
import { Public } from '../../common/decorators/public.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('orgs')
@Controller('orgs')
export class OrgsController {
  constructor(private readonly orgsService: OrgsService) {}

  // Registration by applicationId is handled in AuthController now. Removing legacy /orgs/register endpoint.

  @Public()
  @Post('verify-code')
  @ApiOperation({ summary: 'Verify organization invite code (pre-registration)' })
  @ApiResponse({ status: 200, description: 'Code verified successfully, ready for registration' })
  @ApiResponse({ status: 400, description: 'Invalid or expired invite code' })
  @ApiResponse({ status: 404, description: 'Application not found' })
  async verifyCode(@Body() verifyCodeDto: VerifyCodeDto) {
    return this.orgsService.verifyApplicationCode(verifyCodeDto.applicationId, verifyCodeDto.inviteCode);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post('verify-with-code')
  @ApiOperation({ summary: 'Verify organization with invite code (authenticated)' })
  @ApiResponse({ status: 200, description: 'Organization verified successfully' })
  @ApiResponse({ status: 400, description: 'Invalid or expired invite code' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async verifyWithInviteCode(@Request() req: any, @Body() verifyInviteCodeDto: VerifyInviteCodeDto) {
    return this.orgsService.verifyWithInviteCode(req.user.orgId, verifyInviteCodeDto.inviteCode);
  }

  @Public()
  @Post('verify')
  @ApiOperation({ summary: 'Request organization verification (legacy)', deprecated: true })
  @ApiResponse({ status: 201, description: 'Verification request submitted successfully' })
  @ApiResponse({ status: 409, description: 'Organization username already exists' })
  async requestVerification(@Body() verifyOrgDto: VerifyOrgDto) {
    return this.orgsService.requestVerification(verifyOrgDto);
  }

  @Public()
  @Get()
  @ApiOperation({ summary: 'Get organizations by country' })
  @ApiResponse({ status: 200, description: 'Organizations retrieved successfully' })
  async getOrganizations(@Query('country') country?: string) {
    if (!country) {
      return []; // Return empty array if no country specified
    }
    return this.orgsService.findByCountry(country);
  }

  @Public()
  @Get('status')
  @ApiOperation({ summary: 'Get organization verification status by username', deprecated: true })
  @ApiResponse({ status: 200, description: 'Status retrieved successfully' })
  async getStatusByUsername(@Query('username') username: string) {
    if (!username) {
      return { verificationStatus: 'pending' };
    }
    const org = await this.orgsService.findByUsername(username);
    return { verificationStatus: org?.verificationStatus ?? 'pending' };
  }

  @Public()
  @Get('applications/:id/status')
  @ApiOperation({ summary: 'Get organization verification status by application id' })
  @ApiResponse({ status: 200, description: 'Status retrieved successfully' })
  async getStatusByApplicationId(@Param('id') id: string) {
    if (!id) {
      return { verificationStatus: 'pending' };
    }
    const org = await this.orgsService.findById(id);
    return { verificationStatus: org?.verificationStatus ?? 'pending' };
  }

  @Public()
  @Get('by-username')
  @ApiOperation({ summary: 'Get organization minimal info by username' })
  @ApiResponse({ status: 200, description: 'Organization retrieved successfully' })
  async getByUsername(@Query('username') username: string) {
    if (!username) {
      return null;
    }
    const org = await this.orgsService.findByUsername(username);
    if (!org) return null;
    return {
      id: org.id,
      username: org.username,
      verificationStatus: org.verificationStatus,
    };
  }
}
