const express = require('express');
const router = express.Router();
const locationController = require('../controllers/location.controller');
const { authenticateToken } = require('../middleware/auth.middleware');

// GET /location/nearby-shops
router.get('/nearby-shops', authenticateToken, locationController.getNearbyShops);

// GET /location/shops
router.get('/shops', authenticateToken, locationController.getShopLocations);

// GET /location/distance
router.get('/distance', authenticateToken, locationController.calculateDistance);

module.exports = router;

