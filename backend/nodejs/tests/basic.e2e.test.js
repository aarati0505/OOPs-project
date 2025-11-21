/**
 * Basic E2E Tests
 * 
 * NOTE: These tests require a running MongoDB instance.
 * Set MONGODB_URI in .env or environment variables.
 * 
 * For local testing:
 * - Start MongoDB: brew services start mongodb-community (macOS)
 * - Or use MongoDB Atlas with a test database
 * 
 * TODO: Consider using mongodb-memory-server for isolated test database
 */

const request = require('supertest');
const app = require('../app');
const { connect: connectDatabase, disconnect: disconnectDatabase } = require('../config/database');

describe('Basic E2E Tests', () => {
  let accessToken;
  let userId;

  beforeAll(async () => {
    // Connect to test database
    try {
      await connectDatabase();
      console.log('✅ Connected to test database');
    } catch (error) {
      console.error('❌ Failed to connect to test database:', error.message);
      console.log('⚠️  Make sure MongoDB is running and MONGODB_URI is set correctly');
      throw error;
    }
  });

  afterAll(async () => {
    // Disconnect from database
    try {
      await disconnectDatabase();
      console.log('✅ Disconnected from test database');
    } catch (error) {
      console.error('❌ Error disconnecting:', error.message);
    }
  });

  describe('Health Check', () => {
    test('GET /health should return 200 with status ok', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);

      expect(response.body).toHaveProperty('success', true);
      expect(response.body).toHaveProperty('data');
      expect(response.body.data).toHaveProperty('status', 'ok');
      expect(response.body.data).toHaveProperty('timestamp');
      expect(response.body.data).toHaveProperty('environment');
    });
  });

  describe('Authentication Flow', () => {
    const testUser = {
      name: 'Test User',
      email: `test-${Date.now()}@example.com`,
      phoneNumber: `+1234567${Date.now().toString().slice(-4)}`,
      password: 'password123',
      role: 'customer',
    };

    test('POST /v1/auth/signup should create a new user', async () => {
      const response = await request(app)
        .post('/v1/auth/signup')
        .send(testUser)
        .expect(200);

      expect(response.body).toHaveProperty('success', true);
      expect(response.body).toHaveProperty('data');
      expect(response.body.data).toHaveProperty('user');
      expect(response.body.data).toHaveProperty('accessToken');
      expect(response.body.data).toHaveProperty('refreshToken');
      expect(response.body.data.user).toHaveProperty('email', testUser.email);
      expect(response.body.data.user).toHaveProperty('role', testUser.role);

      // Save tokens for subsequent tests
      accessToken = response.body.data.accessToken;
      userId = response.body.data.user.id;
    });

    test('POST /v1/auth/login should authenticate existing user', async () => {
      const response = await request(app)
        .post('/v1/auth/login')
        .send({
          emailOrPhone: testUser.email,
          password: testUser.password,
        })
        .expect(200);

      expect(response.body).toHaveProperty('success', true);
      expect(response.body).toHaveProperty('data');
      expect(response.body.data).toHaveProperty('accessToken');
      expect(response.body.data).toHaveProperty('refreshToken');
    });

    test('POST /v1/auth/login should reject invalid credentials', async () => {
      const response = await request(app)
        .post('/v1/auth/login')
        .send({
          emailOrPhone: testUser.email,
          password: 'wrongpassword',
        })
        .expect(401);

      expect(response.body).toHaveProperty('success', false);
      expect(response.body).toHaveProperty('errors');
    });

    test('POST /v1/auth/signup should reject duplicate email', async () => {
      const response = await request(app)
        .post('/v1/auth/signup')
        .send({
          ...testUser,
          email: testUser.email, // Same email
          phoneNumber: `+1234567${Date.now().toString().slice(-4)}`, // Different phone
        })
        .expect(409); // Conflict

      expect(response.body).toHaveProperty('success', false);
    });
  });

  describe('Products API', () => {
    test('GET /v1/products should return 200 with products array (requires auth)', async () => {
      // First, create a test user and get token
      const signupResponse = await request(app)
        .post('/v1/auth/signup')
        .send({
          name: 'Product Test User',
          email: `product-test-${Date.now()}@example.com`,
          phoneNumber: `+1234567${Date.now().toString().slice(-4)}`,
          password: 'password123',
          role: 'customer',
        });

      const token = signupResponse.body.data.accessToken;

      const response = await request(app)
        .get('/v1/products')
        .set('Authorization', `Bearer ${token}`)
        .expect(200);

      expect(response.body).toHaveProperty('success', true);
      expect(response.body).toHaveProperty('data');
      // Response should have data array (even if empty)
      expect(Array.isArray(response.body.data.data) || Array.isArray(response.body.data)).toBe(true);
    });

    test('GET /v1/products should return 401 without authentication', async () => {
      const response = await request(app)
        .get('/v1/products')
        .expect(401);

      expect(response.body).toHaveProperty('success', false);
    });
  });

  describe('Cart API', () => {
    let cartToken;
    let testProductId;

    beforeAll(async () => {
      // Create a test user for cart tests
      const signupResponse = await request(app)
        .post('/v1/auth/signup')
        .send({
          name: 'Cart Test User',
          email: `cart-test-${Date.now()}@example.com`,
          phoneNumber: `+1234567${Date.now().toString().slice(-4)}`,
          password: 'password123',
          role: 'customer',
        });

      cartToken = signupResponse.body.data.accessToken;

      // Note: In a real test, you'd create a product first
      // For now, we'll use a placeholder ID
      testProductId = '507f1f77bcf86cd799439011';
    });

    test('GET /v1/cart should return 200 with cart (requires auth)', async () => {
      const response = await request(app)
        .get('/v1/cart')
        .set('Authorization', `Bearer ${cartToken}`)
        .expect(200);

      expect(response.body).toHaveProperty('success', true);
      expect(response.body).toHaveProperty('data');
      expect(response.body.data).toHaveProperty('items');
      expect(Array.isArray(response.body.data.items)).toBe(true);
    });

    test('GET /v1/cart should return 401 without authentication', async () => {
      const response = await request(app)
        .get('/v1/cart')
        .expect(401);

      expect(response.body).toHaveProperty('success', false);
    });
  });

  describe('Error Handling', () => {
    test('GET /v1/nonexistent should return 404', async () => {
      const response = await request(app)
        .get('/v1/nonexistent')
        .expect(404);

      expect(response.body).toHaveProperty('success', false);
      expect(response.body).toHaveProperty('errors');
    });

    test('POST /v1/auth/signup with invalid data should return 400', async () => {
      const response = await request(app)
        .post('/v1/auth/signup')
        .send({
          name: 'A', // Too short
          email: 'invalid-email', // Invalid format
          password: '123', // Too short
        })
        .expect(400);

      expect(response.body).toHaveProperty('success', false);
      expect(response.body).toHaveProperty('errors');
      expect(Array.isArray(response.body.errors)).toBe(true);
    });
  });
});

