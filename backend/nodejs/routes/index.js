const express = require('express');
const router = express.Router();

// Import all route modules
const authRoutes = require('./auth.routes');
const userRoutes = require('./user.routes');
const productRoutes = require('./product.routes');
const orderRoutes = require('./order.routes');
const cartRoutes = require('./cart.routes');
const inventoryRoutes = require('./inventory.routes');
const categoryRoutes = require('./category.routes');
const reviewRoutes = require('./review.routes');
const locationRoutes = require('./location.routes');
const notificationRoutes = require('./notification.routes');
const retailerRoutes = require('./retailer.routes');
const wholesalerRoutes = require('./wholesaler.routes');

// Mount routes with base paths
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/products', productRoutes);
router.use('/orders', orderRoutes);
router.use('/cart', cartRoutes);
router.use('/inventory', inventoryRoutes);
router.use('/categories', categoryRoutes);
router.use('/reviews', reviewRoutes);
router.use('/location', locationRoutes);
router.use('/notifications', notificationRoutes);
router.use('/retailers', retailerRoutes);
router.use('/wholesalers', wholesalerRoutes);

module.exports = router;

