require('dotenv').config();
const express = require('express');
const cors = require('cors');
const routes = require('./routes');
const { errorHandler, notFoundHandler } = require('./middleware/error.middleware');

const app = express();

// Security: CORS configuration
const corsOptions = {
  origin: process.env.ALLOWED_ORIGINS 
    ? process.env.ALLOWED_ORIGINS.split(',')
    : '*', // TODO: Restrict to specific origins in production
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-user-email'], // Added x-user-email for dev mode
};

app.use(cors(corsOptions));

// Security: Body parsing with size limits
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Security: Basic request logging (without sensitive data)
app.use((req, res, next) => {
  // Don't log sensitive headers or body fields
  const safeReq = {
    method: req.method,
    path: req.path,
    ip: req.ip,
    timestamp: new Date().toISOString(),
  };
  if (process.env.NODE_ENV !== 'production') {
    console.log('Request:', safeReq);
  }
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  const { successResponse } = require('./utils/response.util');
  res.json(successResponse({
    status: 'ok',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
  }, 'Service is healthy'));
});

// API routes with /v1 prefix (matching Dart API base URL)
app.use('/v1', routes);

// Error handling middleware (must be last)
app.use(notFoundHandler);
app.use(errorHandler);

module.exports = app;

