import { Controller, Post, Body, UseGuards, Get, UnauthorizedException, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiBody } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { AuthService } from './auth.service';
import { OrgLoginDto } from './dto/org-login.dto';
import { RegisterOrgDto } from '../orgs/dto/register-org.dto';
import { ActivateAccountDto } from './dto/activate-account.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Public } from '../../common/decorators/public.decorator';
import { OrgUser } from '../../common/interfaces/user.interface';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('org/register/by-application/:applicationId')
  async orgRegisterByApplication(
    @Param('applicationId') applicationId: string,
    @Body() body: any,
  ) {
    const { username, password } = body || {};
    return this.authService.orgRegisterByApplicationId(applicationId, username, password);
  }

  @Public()
  @Throttle({ default: { limit: 5, ttl: 900000 } }) // 5 attempts per 15 minutes
  @Post('org/login')
  @ApiOperation({ summary: 'Organization login' })
  @ApiResponse({ status: 200, description: 'Login successful, returns JWT token' })
  @ApiResponse({ status: 401, description: 'Invalid credentials or org not authorized (rejected)' })
  @ApiResponse({ status: 429, description: 'Too many login attempts' })
  async orgLogin(@Body() orgLoginDto: OrgLoginDto) {
    return this.authService.orgLogin(orgLoginDto);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @Get('org/profile')
  @ApiOperation({ summary: 'Get current organization profile' })
  @ApiResponse({ status: 200, description: 'Organization profile retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Invalid or expired token' })
  async getOrgProfile(@CurrentUser() org: OrgUser) {
    return org;
  }

  @Public()
  @Post('refresh')
  @ApiOperation({ summary: 'Refresh access token using refresh token' })
  @ApiResponse({ status: 200, description: 'Token refreshed successfully' })
  @ApiResponse({ status: 401, description: 'Invalid or expired refresh token' })
  async refreshToken(@Body('refreshToken') refreshToken: string) {
    if (!refreshToken) {
      throw new UnauthorizedException('Refresh token is required');
    }
    return this.authService.refreshToken(refreshToken);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @Post('org/activate')
  @ApiOperation({ summary: 'Activate organization account with invite code' })
  @ApiResponse({ status: 200, description: 'Account activated successfully' })
  @ApiResponse({ status: 400, description: 'Invalid or expired invite code' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async activateAccount(
    @CurrentUser() org: OrgUser,
    @Body() activateAccountDto: ActivateAccountDto,
  ) {
    return this.authService.activateAccount(org.id, activateAccountDto);
  }
}
