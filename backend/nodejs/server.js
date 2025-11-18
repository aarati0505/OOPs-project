// Node.js + Express Backend Server
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors()); // Allow Flutter app to make requests
app.use(morgan('dev'));
app.use(express.json()); // Parse JSON bodies
app.use(express.urlencoded({ extended: true }));

// Routes - These match your Flutter API endpoints
app.use('/v1/auth', require('./routes/auth.routes'));
app.use('/v1/products', require('./routes/products.routes'));
app.use('/v1/orders', require('./routes/orders.routes'));
app.use('/v1/inventory', require('./routes/inventory.routes'));
app.use('/v1/cart', require('./routes/cart.routes'));
app.use('/v1/users', require('./routes/users.routes'));
app.use('/v1/reviews', require('./routes/reviews.routes'));
app.use('/v1/location', require('./routes/location.routes'));
app.use('/v1/categories', require('./routes/categories.routes'));
app.use('/v1/notifications', require('./routes/notifications.routes'));
app.use('/v1/payment', require('./routes/payment.routes'));

// Retailer specific routes
app.use('/v1/retailers/orders', require('./routes/retailer-orders.routes'));

// Wholesaler specific routes
app.use('/v1/wholesalers/orders', require('./routes/wholesaler-orders.routes'));

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Server is running' });
});

// Error handling middleware
app.use(require('./middleware/errorHandler.middleware'));

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`API base URL: http://localhost:${PORT}/v1`);
});

module.exports = app;

