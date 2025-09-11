import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  UseGuards,
  Query,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { ProtestsService } from './protests.service';
import { CreateProtestDto } from './dto/create-protest.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Public } from '../../common/decorators/public.decorator';
import { PaginationQueryDto } from '../../common/dto/pagination.dto';
import { OrgUser } from '../../common/interfaces/user.interface';

@ApiTags('protests')
@Controller('protests')
export class ProtestsController {
  constructor(private readonly protestsService: ProtestsService) {}

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @Post()
  @ApiOperation({ summary: 'Create a new protest' })
  @ApiResponse({ status: 201, description: 'Protest created successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized - invalid token' })
  create(@Body() createProtestDto: CreateProtestDto, @CurrentUser() org: OrgUser) {
    return this.protestsService.create(createProtestDto, org.id);
  }

  @Public()
  @Get()
  @ApiOperation({ summary: 'Get paginated protests feed' })
  @ApiResponse({ status: 200, description: 'Protests feed retrieved successfully' })
  findAll(@Query() paginationQuery: PaginationQueryDto) {
    return this.protestsService.findAll(paginationQuery);
  }

  @Public()
  @Get(':id')
  @ApiOperation({ summary: 'Get protest details by ID' })
  @ApiResponse({ status: 200, description: 'Protest details retrieved successfully' })
  @ApiResponse({ status: 404, description: 'Protest not found' })
  findOne(@Param('id') id: string) {
    return this.protestsService.findById(id);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @Delete(':id')
  @ApiOperation({ summary: 'Delete a protest (Organization only - can delete own protests)' })
  @ApiResponse({ status: 200, description: 'Protest deleted successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Organization access required' })
  @ApiResponse({ status: 404, description: 'Protest not found' })
  async deleteProtest(@Param('id') id: string, @CurrentUser() org: OrgUser) {
    return this.protestsService.delete(id, org.id);
  }
}
