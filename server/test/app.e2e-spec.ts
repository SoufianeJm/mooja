import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Mooja API (e2e)', () => {
  let app: INestApplication;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    
    // Apply same configuration as main.ts
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        transform: true,
        forbidNonWhitelisted: true,
      }),
    );
    app.setGlobalPrefix('api');
    
    await app.init();
  });

  afterEach(async () => {
    await app.close();
  });

  describe('/api/protests (GET)', () => {
    it('should return paginated protests feed', () => {
      return request(app.getHttpServer())
        .get('/api/protests')
        .expect(200)
        .expect((res) => {
          // For now, just verify basic structure since we have no data
          expect(res.body).toHaveProperty('data');
          expect(Array.isArray(res.body.data)).toBe(true);
          // The pagination structure might vary based on the implementation
          if (res.body.pagination) {
            expect(res.body.pagination).toHaveProperty('hasNextPage');
            expect(res.body.pagination).toHaveProperty('limit');
          }
        });
    });

    it('should handle pagination query parameters', () => {
      return request(app.getHttpServer())
        .get('/api/protests?limit=2')
        .expect(200);
    });
  });

  describe('/api/orgs/verify (POST)', () => {
    it('should accept org verification request', () => {
      const uniqueUsername = `test_org_e2e_${Date.now()}`;
      return request(app.getHttpServer())
        .post('/api/orgs/verify')
        .send({
          username: uniqueUsername,
          country: 'Canada',
          socialMediaPlatform: 'Twitter',
          socialMediaHandle: `@${uniqueUsername}`,
        })
        .expect(201);
    });

    it('should validate required fields', () => {
      return request(app.getHttpServer())
        .post('/api/orgs/verify')
        .send({
          username: 'test_org_e2e',
          // Missing required country field
        })
        .expect(400);
    });
  });

  describe('/api/auth/org/login (POST)', () => {
    it('should reject invalid credentials', () => {
      return request(app.getHttpServer())
        .post('/api/auth/org/login')
        .send({
          username: 'nonexistent_org',
          password: 'wrongpassword',
        })
        .expect(401);
    });

    it('should validate required fields', () => {
      return request(app.getHttpServer())
        .post('/api/auth/org/login')
        .send({
          username: 'test_org',
          // Missing password
        })
        .expect(400);
    });
  });
});
