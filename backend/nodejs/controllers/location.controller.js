const User = require('../models/User');
const Product = require('../models/Product');
const { successResponse, errorResponse, createApiError } = require('../utils/response.util');

/**
 * Location Controller
 * Matching Dart LocationApiService methods
 */

/**
 * Helper function to calculate distance (Haversine formula)
 */
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Earth's radius in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c; // Distance in km
}

/**
 * GET /location/nearby-shops
 * Get nearby shops
 * Matching: LocationApiService.getNearbyShops()
 */
exports.getNearbyShops = async (req, res) => {
  try {
    const { latitude, longitude, maxDistance, category } = req.query;

    if (!latitude || !longitude || !maxDistance) {
      return res.status(400).json(
        errorResponse(
          [createApiError('location', 'Latitude, longitude, and maxDistance are required')],
          'Validation error'
        )
      );
    }

    const lat = parseFloat(latitude);
    const lng = parseFloat(longitude);
    const maxDist = parseFloat(maxDistance);

    // Find retailers/wholesalers with location data
    const query = {
      role: { $in: ['retailer', 'wholesaler'] },
      location: { $exists: true, $ne: null },
    };

    if (category) {
      // TODO: Filter by category if needed
    }

    const shops = await User.find(query).lean();

    // Calculate distances and filter
    const nearbyShops = shops
      .map(shop => {
        if (!shop.location?.lat || !shop.location?.lng) return null;

        const distance = calculateDistance(
          lat,
          lng,
          shop.location.lat,
          shop.location.lng
        );

        if (distance <= maxDist) {
          return {
            id: shop._id.toString(),
            name: shop.businessName || shop.name,
            retailerId: shop.role === 'retailer' ? shop._id.toString() : null,
            wholesalerId: shop.role === 'wholesaler' ? shop._id.toString() : null,
            latitude: shop.location.lat,
            longitude: shop.location.lng,
            address: shop.businessAddress || shop.location.city || '',
            distanceFromUser: parseFloat(distance.toFixed(2)),
            phone: shop.phone,
            email: shop.email,
          };
        }
        return null;
      })
      .filter(shop => shop !== null)
      .sort((a, b) => a.distanceFromUser - b.distanceFromUser);

    res.json(successResponse(nearbyShops));
  } catch (error) {
    console.error('Get nearby shops error:', error);
    res.status(500).json(errorResponse(createApiError('location', error.message), 'Failed to get nearby shops'));
  }
};

/**
 * GET /location/shops
 * Get shop locations by retailer/wholesaler
 * Matching: LocationApiService.getShopLocations()
 */
exports.getShopLocations = async (req, res) => {
  try {
    const { retailerId, wholesalerId } = req.query;

    const query = {
      role: { $in: ['retailer', 'wholesaler'] },
      location: { $exists: true, $ne: null },
    };

    if (retailerId) {
      query._id = retailerId;
      query.role = 'retailer';
    } else if (wholesalerId) {
      query._id = wholesalerId;
      query.role = 'wholesaler';
    }

    const shops = await User.find(query).lean();

    const shopsResponse = shops.map(shop => ({
      id: shop._id.toString(),
      name: shop.businessName || shop.name,
      retailerId: shop.role === 'retailer' ? shop._id.toString() : null,
      wholesalerId: shop.role === 'wholesaler' ? shop._id.toString() : null,
      latitude: shop.location.lat,
      longitude: shop.location.lng,
      address: shop.businessAddress || shop.location.city || '',
      phone: shop.phone,
      email: shop.email,
    }));

    res.json(successResponse(shopsResponse));
  } catch (error) {
    console.error('Get shop locations error:', error);
    res.status(500).json(errorResponse(createApiError('location', error.message), 'Failed to get shop locations'));
  }
};

/**
 * GET /location/distance
 * Calculate distance between two points
 * Matching: LocationApiService.calculateDistance()
 */
exports.calculateDistance = async (req, res) => {
  try {
    const { lat1, lon1, lat2, lon2 } = req.query;

    if (!lat1 || !lon1 || !lat2 || !lon2) {
      return res.status(400).json(
        errorResponse(
          [createApiError('location', 'All coordinates are required')],
          'Validation error'
        )
      );
    }

    const distance = calculateDistance(
      parseFloat(lat1),
      parseFloat(lon1),
      parseFloat(lat2),
      parseFloat(lon2)
    );

    // Estimate duration (rough approximation: 30 km/h average speed)
    const duration = (distance / 30) * 60; // in minutes

    const distanceResponse = {
      distance: parseFloat(distance.toFixed(2)),
      duration: parseFloat(duration.toFixed(2)),
    };

    res.json(successResponse(distanceResponse));
  } catch (error) {
    console.error('Calculate distance error:', error);
    res.status(500).json(errorResponse(createApiError('location', error.message), 'Failed to calculate distance'));
  }
};
