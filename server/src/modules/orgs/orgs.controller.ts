import { Controller, Post, Body, Patch, Request, UseGuards, Get, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { OrgsService } from './orgs.service';
import { VerifyOrgDto } from './dto/verify-org.dto';
import { RegisterOrgDto } from './dto/register-org.dto';
import { VerifyInviteCodeDto } from './dto/verify-invite-code.dto';
import { Public } from '../../common/decorators/public.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('orgs')
@Controller('orgs')
export class OrgsController {
  constructor(private readonly orgsService: OrgsService) {}

  @Public()
  @Post('register')
  @ApiOperation({ summary: 'Register a new organization' })
  @ApiResponse({ status: 201, description: 'Organization registered successfully' })
  @ApiResponse({ status: 409, description: 'Organization username already exists' })
  async register(@Body() registerOrgDto: RegisterOrgDto) {
    return this.orgsService.register(registerOrgDto);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post('verify-with-code')
  @ApiOperation({ summary: 'Verify organization with invite code' })
  @ApiResponse({ status: 200, description: 'Organization verified successfully' })
  @ApiResponse({ status: 400, description: 'Invalid or expired invite code' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async verifyWithInviteCode(@Request() req: any, @Body() verifyInviteCodeDto: VerifyInviteCodeDto) {
    return this.orgsService.verifyWithInviteCode(req.user.orgId, verifyInviteCodeDto.inviteCode);
  }

  @Public()
  @Post('verify')
  @ApiOperation({ summary: 'Request organization verification (legacy)' })
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
}
