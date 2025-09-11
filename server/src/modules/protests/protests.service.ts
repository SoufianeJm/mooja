import { Injectable, NotFoundException } from '@nestjs/common';
import { plainToInstance } from 'class-transformer';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateProtestDto } from './dto/create-protest.dto';
import { ProtestResponseDto, CreateProtestResponseDto } from './dto/protest-response.dto';
import { PaginationQueryDto, PaginatedResponseDto } from '../../common/dto/pagination.dto';
import { APP_CONSTANTS, MESSAGES } from '../../common/constants/app.constants';

@Injectable()
export class ProtestsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createProtestDto: CreateProtestDto, orgId: string) {
    const protest = await this.prisma.protest.create({
      data: {
        title: createProtestDto.title,
        dateTime: new Date(createProtestDto.dateTime),
        country: createProtestDto.country,
        city: createProtestDto.city,
        location: createProtestDto.location,
        pictureUrl: createProtestDto.pictureUrl,
        description: createProtestDto.description,
        organizerId: orgId,
      },
      include: {
        organizer: {
          select: {
            id: true,
            username: true,
            name: true,
            pictureUrl: true,
            country: true,
            verificationStatus: true,
            socialMediaPlatform: true,
            socialMediaHandle: true,
          },
        },
      },
    });

    const response = {
      message: MESSAGES.SUCCESS.PROTEST_CREATED,
      protest,
    };
    
    return plainToInstance(CreateProtestResponseDto, response, { 
      excludeExtraneousValues: true 
    });
  }

  async findAll(paginationQuery: PaginationQueryDto) {
    const { cursor, limit = APP_CONSTANTS.PAGINATION.DEFAULT_LIMIT, country } = paginationQuery;
    const take = Math.min(limit, APP_CONSTANTS.PAGINATION.MAX_LIMIT); // Enforce max items for good UX
    
    // Build where clause for cursor pagination, future protests, and country filter
    const whereClause: {
      dateTime: { gte: Date };
      id?: { gt: string };
      country?: string;
    } = {
      dateTime: {
        gte: new Date(), // Only show future protests
      },
    };
    
    // Add country filter if provided
    if (country) {
      whereClause.country = country;
    }
    
    // Add cursor condition for pagination
    if (cursor) {
      whereClause.id = {
        gt: cursor, // Get protests after this cursor ID
      };
    }

    // Efficient pagination - fetch one extra record to check for next page
    const protests = await this.prisma.protest.findMany({
      where: whereClause,
      include: {
        organizer: {
          select: {
            id: true,
            username: true,
            name: true,
            pictureUrl: true,
            country: true,
            verificationStatus: true,
            socialMediaPlatform: true,
            socialMediaHandle: true,
          },
        },
      },
      orderBy: [
        { dateTime: 'asc' }, // Show upcoming protests first
        { id: 'asc' }, // Secondary sort for consistent pagination
      ],
      take: take + 1, // Fetch one extra to check for next page
    });

    // Determine pagination status from the extra record
    const hasNextPage = protests.length > take;
    let nextCursor: string | undefined;
    
    if (hasNextPage) {
      // Remove the extra record and use the last actual record's ID as cursor
      protests.pop();
      nextCursor = protests[protests.length - 1].id;
    }

    return new PaginatedResponseDto(protests, nextCursor, take);
  }

  async findById(id: string) {
    const protest = await this.prisma.protest.findUnique({
      where: { id },
      include: {
        organizer: {
          select: {
            id: true,
            username: true,
            name: true,
            pictureUrl: true,
            country: true,
            verificationStatus: true,
            socialMediaPlatform: true,
            socialMediaHandle: true,
          },
        },
      },
    });

    if (!protest) {
      throw new NotFoundException(`Protest with ID '${id}' not found`);
    }

    return plainToInstance(ProtestResponseDto, protest, { 
      excludeExtraneousValues: true 
    });
  }

  async delete(id: string, orgId: string) {
    // First check if the protest exists and belongs to the organization
    const protest = await this.prisma.protest.findUnique({
      where: { id },
    });

    if (!protest) {
      throw new NotFoundException(`Protest with ID '${id}' not found`);
    }

    // Check if the organization owns this protest
    if (protest.organizerId !== orgId) {
      throw new NotFoundException(`Protest with ID '${id}' not found`); // Return not found to avoid revealing existence
    }

    // Delete the protest
    await this.prisma.protest.delete({
      where: { id },
    });

    return {
      message: 'Protest deleted successfully',
      deletedProtest: {
        id: protest.id,
        title: protest.title,
      },
    };
  }
}
