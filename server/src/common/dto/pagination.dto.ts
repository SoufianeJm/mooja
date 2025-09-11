import { IsOptional, IsString, IsInt, Min, Max } from 'class-validator';
import { Transform } from 'class-transformer';
import { APP_CONSTANTS } from '../constants/app.constants';

export class PaginationQueryDto {
  @IsOptional()
  @IsString()
  cursor?: string; // The ID of the last item from previous page

  @IsOptional()
  @Transform(({ value }) => {
    if (typeof value === 'string') {
      const parsed = parseInt(value, 10);
      if (isNaN(parsed)) {
        throw new Error(`Invalid limit value: ${value}`);
      }
      return parsed;
    }
    return value;
  })
  @IsInt()
  @Min(APP_CONSTANTS.PAGINATION.MIN_LIMIT)
  @Max(APP_CONSTANTS.PAGINATION.MAX_LIMIT) // Maximum items for good UX
  limit?: number = APP_CONSTANTS.PAGINATION.DEFAULT_LIMIT; // Default limit

  @IsOptional()
  @IsString()
  country?: string; // Optional country filter (client-side for MVP)
}

export class PaginatedResponseDto<T> {
  data: T[];
  pagination: {
    nextCursor?: string;
    hasNextPage: boolean;
    limit: number;
    total?: number; // Optional, can be expensive to calculate
  };

  constructor(data: T[], nextCursor?: string, limit: number = APP_CONSTANTS.PAGINATION.DEFAULT_LIMIT, total?: number) {
    this.data = data;
    this.pagination = {
      nextCursor,
      hasNextPage: !!nextCursor,
      limit,
      total,
    };
  }
}
