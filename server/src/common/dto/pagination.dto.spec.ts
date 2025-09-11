import { validate } from 'class-validator';
import { plainToClass } from 'class-transformer';
import { PaginationQueryDto } from './pagination.dto';
import { APP_CONSTANTS } from '../constants/app.constants';

describe('PaginationQueryDto', () => {
  describe('Validation', () => {
    it('should pass validation with valid limit', async () => {
      const dto = plainToClass(PaginationQueryDto, {
        limit: '10',
      });

      const errors = await validate(dto);
      expect(errors).toHaveLength(0);
      expect(dto.limit).toBe(10);
    });

    it('should use default limit when not provided', async () => {
      const dto = plainToClass(PaginationQueryDto, {});

      const errors = await validate(dto);
      expect(errors).toHaveLength(0);
      expect(dto.limit).toBe(APP_CONSTANTS.PAGINATION.DEFAULT_LIMIT);
    });

    it('should enforce minimum limit value', async () => {
      const dto = plainToClass(PaginationQueryDto, {
        limit: '0',
      });

      const errors = await validate(dto);
      expect(errors.length).toBeGreaterThan(0);
    });

    it('should enforce maximum limit value', async () => {
      const dto = plainToClass(PaginationQueryDto, {
        limit: String(APP_CONSTANTS.PAGINATION.MAX_LIMIT + 1),
      });

      const errors = await validate(dto);
      expect(errors.length).toBeGreaterThan(0);
    });

    it('should handle invalid limit gracefully', async () => {
      expect(() => {
        plainToClass(PaginationQueryDto, {
          limit: 'not-a-number',
        });
      }).toThrow('Invalid limit value: not-a-number');
    });

    it('should accept optional cursor', async () => {
      const dto = plainToClass(PaginationQueryDto, {
        cursor: 'some-cursor-id',
        limit: '5',
      });

      const errors = await validate(dto);
      expect(errors).toHaveLength(0);
      expect(dto.cursor).toBe('some-cursor-id');
      expect(dto.limit).toBe(5);
    });

    it('should accept optional country filter', async () => {
      const dto = plainToClass(PaginationQueryDto, {
        country: 'Canada',
        limit: '5',
      });

      const errors = await validate(dto);
      expect(errors).toHaveLength(0);
      expect(dto.country).toBe('Canada');
      expect(dto.limit).toBe(5);
    });
  });

  describe('Type Safety and Security', () => {
    it('should handle string limit conversion properly', () => {
      const dto = plainToClass(PaginationQueryDto, {
        limit: '15',
      });

      expect(typeof dto.limit).toBe('number');
      expect(dto.limit).toBe(15);
    });

    it('should reject non-string cursor', async () => {
      const dto = plainToClass(PaginationQueryDto, {
        cursor: 123,
      });

      const errors = await validate(dto);
      expect(errors.length).toBeGreaterThan(0);
    });

    it('should reject non-string country', async () => {
      const dto = plainToClass(PaginationQueryDto, {
        country: 123,
      });

      const errors = await validate(dto);
      expect(errors.length).toBeGreaterThan(0);
    });
  });

  describe('Integration with Constants', () => {
    it('should use values from APP_CONSTANTS', () => {
      const dto = plainToClass(PaginationQueryDto, {});
      
      expect(dto.limit).toBe(APP_CONSTANTS.PAGINATION.DEFAULT_LIMIT);
    });

    it('should respect MAX_LIMIT from constants', async () => {
      const dto = plainToClass(PaginationQueryDto, {
        limit: String(APP_CONSTANTS.PAGINATION.MAX_LIMIT),
      });

      const errors = await validate(dto);
      expect(errors).toHaveLength(0);

      // Test exceeding the limit
      const dto2 = plainToClass(PaginationQueryDto, {
        limit: String(APP_CONSTANTS.PAGINATION.MAX_LIMIT + 1),
      });

      const errors2 = await validate(dto2);
      expect(errors2.length).toBeGreaterThan(0);
    });

    it('should respect MIN_LIMIT from constants', async () => {
      const dto = plainToClass(PaginationQueryDto, {
        limit: String(APP_CONSTANTS.PAGINATION.MIN_LIMIT),
      });

      const errors = await validate(dto);
      expect(errors).toHaveLength(0);

      // Test below minimum
      const dto2 = plainToClass(PaginationQueryDto, {
        limit: String(APP_CONSTANTS.PAGINATION.MIN_LIMIT - 1),
      });

      const errors2 = await validate(dto2);
      expect(errors2.length).toBeGreaterThan(0);
    });
  });
});
