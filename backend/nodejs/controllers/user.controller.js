const User = require('../models/User');
const Address = require('../models/Address');
const { resolveUserLocation } = require('../services/location.service');
const { successResponse, errorResponse, createApiError } = require('../utils/response.util');

/**
 * User Controller
 * Matching Dart UserApiService methods
 */

/**
 * GET /users/profile
 * Get user profile
 * Matching: UserApiService.getUserProfile()
 */
exports.getUserProfile = async (req, res) => {
  try {
    const [user, addresses] = await Promise.all([
      User.findById(req.user._id).select('-passwordHash -refreshToken'),
      Address.find({ userId: req.user._id }).sort({ isDefault: -1, createdAt: -1 }),
    ]);

    if (!user) {
      return res.status(404).json(
        errorResponse(
          [createApiError('user', 'User not found')],
          'User not found'
        )
      );
    }

    // Format response matching Dart UserModel
    const userResponse = {
      id: user._id.toString(),
      name: user.name,
      email: user.email,
      phoneNumber: user.phone,
      role: user.role,
      isEmailVerified: user.isEmailVerified,
      isPhoneVerified: user.isPhoneVerified,
      createdAt: user.createdAt.toISOString(),
      lastLoginAt: user.lastLoginAt?.toISOString(),
      businessName: user.businessName,
      businessAddress: user.businessAddress,
      location: user.location,
      addresses: addresses.map(addr => ({
        id: addr._id.toString(),
        label: addr.label,
        line1: addr.line1,
        line2: addr.line2,
        city: addr.city,
        region: addr.region,
        pincode: addr.pincode,
        lat: addr.lat,
        lng: addr.lng,
        isDefault: addr.isDefault,
      })),
    };

    res.json(successResponse(userResponse));
  } catch (error) {
    console.error('Get user profile error:', error);
    res.status(500).json(errorResponse(createApiError('user', error.message), 'Failed to get user profile'));
  }
};

/**
 * PUT /users/profile
 * Update user profile
 * Matching: UserApiService.updateProfile()
 */
exports.updateProfile = async (req, res) => {
  try {
    const updates = req.body;
    const allowedUpdates = ['name', 'phone', 'businessName', 'businessAddress'];
    const updateData = {};

    allowedUpdates.forEach(field => {
      if (updates[field] !== undefined) {
        updateData[field] = updates[field];
      }
    });

    if (updates.locationInput || updates.location) {
      const normalizedLocation = await resolveUserLocation(updates.locationInput || updates.location);
      if (normalizedLocation) {
        updateData.location = normalizedLocation;
      }
    }

    const user = await User.findByIdAndUpdate(
      req.user._id,
      { $set: updateData },
      { new: true, runValidators: true }
    ).select('-passwordHash -refreshToken');

    if (!user) {
      return res.status(404).json(
        errorResponse(
          [createApiError('user', 'User not found')],
          'User not found'
        )
      );
    }

    const userResponse = {
      id: user._id.toString(),
      name: user.name,
      email: user.email,
      phoneNumber: user.phone,
      role: user.role,
      isEmailVerified: user.isEmailVerified,
      isPhoneVerified: user.isPhoneVerified,
      createdAt: user.createdAt.toISOString(),
      businessName: user.businessName,
      businessAddress: user.businessAddress,
      location: user.location,
    };

    res.json(successResponse(userResponse, 'Profile updated successfully'));
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json(errorResponse(createApiError('user', error.message), 'Failed to update profile'));
  }
};

/**
 * POST /users/change-password
 * Change user password
 * Matching: UserApiService.changePassword()
 */
exports.changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json(
        errorResponse(
          [createApiError('user', 'Current password and new password are required')],
          'Validation error'
        )
      );
    }

    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json(
        errorResponse(
          [createApiError('user', 'User not found')],
          'User not found'
        )
      );
    }

    // Verify current password
    const { comparePassword } = require('../services/auth.service');
    const isPasswordValid = await comparePassword(currentPassword, user.passwordHash);
    if (!isPasswordValid) {
      return res.status(401).json(
        errorResponse(
          [createApiError('user', 'Current password is incorrect')],
          'Password change failed'
        )
      );
    }

    // Hash new password
    const { hashPassword } = require('../services/auth.service');
    user.passwordHash = await hashPassword(newPassword);
    await user.save();

    res.json(successResponse(null, 'Password changed successfully'));
  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json(errorResponse(createApiError('user', error.message), 'Failed to change password'));
  }
};

/**
 * GET /users/addresses
 * Get user addresses
 * Matching: UserApiService.getUserAddresses()
 */
exports.getUserAddresses = async (req, res) => {
  try {
    const addresses = await Address.find({ userId: req.user._id }).sort({ isDefault: -1, createdAt: -1 });

    const addressesResponse = addresses.map(addr => ({
      id: addr._id.toString(),
      label: addr.label,
      line1: addr.line1,
      line2: addr.line2,
      city: addr.city,
      region: addr.region,
      pincode: addr.pincode,
      lat: addr.lat,
      lng: addr.lng,
      isDefault: addr.isDefault,
      createdAt: addr.createdAt.toISOString(),
    }));

    res.json(successResponse(addressesResponse));
  } catch (error) {
    console.error('Get addresses error:', error);
    res.status(500).json(errorResponse(createApiError('user', error.message), 'Failed to get addresses'));
  }
};

/**
 * POST /users/addresses
 * Add user address
 * Matching: UserApiService.addAddress()
 */
exports.addAddress = async (req, res) => {
  try {
    const { label, line1, line2, city, region, pincode, lat, lng, isDefault } = req.body;

    if (!label || !line1 || !city || !region || !pincode) {
      return res.status(400).json(
        errorResponse(
          [createApiError('user', 'Required address fields are missing')],
          'Validation error'
        )
      );
    }

    const addressData = {
      userId: req.user._id,
      label,
      line1,
      line2,
      city,
      region,
      pincode,
      lat,
      lng,
      isDefault: isDefault || false,
    };

    const address = new Address(addressData);
    await address.save();

    const addressResponse = {
      id: address._id.toString(),
      label: address.label,
      line1: address.line1,
      line2: address.line2,
      city: address.city,
      region: address.region,
      pincode: address.pincode,
      lat: address.lat,
      lng: address.lng,
      isDefault: address.isDefault,
      createdAt: address.createdAt.toISOString(),
    };

    res.json(successResponse(addressResponse, 'Address added successfully'));
  } catch (error) {
    console.error('Add address error:', error);
    res.status(500).json(errorResponse(createApiError('user', error.message), 'Failed to add address'));
  }
};

/**
 * PUT /users/addresses/:addressId
 * Update user address
 * Matching: UserApiService.updateAddress()
 */
exports.updateAddress = async (req, res) => {
  try {
    const { addressId } = req.params;
    const updates = req.body;

    const address = await Address.findOne({ _id: addressId, userId: req.user._id });
    if (!address) {
      return res.status(404).json(
        errorResponse(
          [createApiError('user', 'Address not found')],
          'Address not found'
        )
      );
    }

    // Update fields
    Object.keys(updates).forEach(key => {
      if (['label', 'line1', 'line2', 'city', 'region', 'pincode', 'lat', 'lng', 'isDefault'].includes(key)) {
        address[key] = updates[key];
      }
    });

    await address.save();

    const addressResponse = {
      id: address._id.toString(),
      label: address.label,
      line1: address.line1,
      line2: address.line2,
      city: address.city,
      region: address.region,
      pincode: address.pincode,
      lat: address.lat,
      lng: address.lng,
      isDefault: address.isDefault,
      updatedAt: address.updatedAt.toISOString(),
    };

    res.json(successResponse(addressResponse, 'Address updated successfully'));
  } catch (error) {
    console.error('Update address error:', error);
    res.status(500).json(errorResponse(createApiError('user', error.message), 'Failed to update address'));
  }
};

/**
 * DELETE /users/addresses/:addressId
 * Delete user address
 * Matching: UserApiService.deleteAddress()
 */
exports.deleteAddress = async (req, res) => {
  try {
    const { addressId } = req.params;

    const address = await Address.findOneAndDelete({ _id: addressId, userId: req.user._id });
    if (!address) {
      return res.status(404).json(
        errorResponse(
          [createApiError('user', 'Address not found')],
          'Address not found'
        )
      );
    }

    res.json(successResponse(null, 'Address deleted successfully'));
  } catch (error) {
    console.error('Delete address error:', error);
    res.status(500).json(errorResponse(createApiError('user', error.message), 'Failed to delete address'));
  }
};

/**
 * GET /users/dashboard
 * Get user dashboard with role-specific analytics
 * Matching: UserApiService.getDashboard()
 */
exports.getDashboard = async (req, res) => {
  try {
    const user = req.user;
    const Order = require('../models/Order');
    const Product = require('../models/Product');
    const Notification = require('../models/Notification');

    let dashboardData = {};

    if (user.role === 'customer') {
      // Customer Dashboard
      const [recentOrders, notifications, localProducts, orderStats] = await Promise.all([
        Order.find({ userId: user._id })
          .sort({ createdAt: -1 })
          .limit(5)
          .populate('items.productId', 'name images')
          .lean(),
        Notification.find({ userId: user._id, isRead: false })
          .sort({ createdAt: -1 })
          .limit(10)
          .lean(),
        Product.find({ 
          isActive: true, 
          isLocal: true, 
          region: user.location?.region,
          stock: { $gt: 0 }
        })
          .sort({ rating: -1, reviewCount: -1 })
          .limit(10)
          .populate('categoryId', 'name')
          .lean(),
        Order.aggregate([
          { $match: { userId: user._id } },
          { $group: { 
            _id: null, 
            totalOrders: { $sum: 1 },
            totalSpent: { $sum: '$finalAmount' },
            pendingOrders: { 
              $sum: { $cond: [{ $eq: ['$status', 'pending'] }, 1, 0] } 
            },
            deliveredOrders: { 
              $sum: { $cond: [{ $eq: ['$status', 'delivered'] }, 1, 0] } 
            }
          }}
        ])
      ]);

      dashboardData = {
        role: 'customer',
        stats: {
          totalOrders: orderStats[0]?.totalOrders || 0,
          totalSpent: orderStats[0]?.totalSpent || 0,
          pendingOrders: orderStats[0]?.pendingOrders || 0,
          deliveredOrders: orderStats[0]?.deliveredOrders || 0,
        },
        recentOrders: recentOrders.map(order => ({
          id: order._id.toString(),
          totalAmount: order.finalAmount,
          status: order.status,
          itemCount: order.items.length,
          createdAt: order.createdAt.toISOString(),
        })),
        recommendedProducts: localProducts.map(product => ({
          id: product._id.toString(),
          name: product.name,
          price: product.price,
          category: product.categoryId?.name || '',
          imageUrl: product.images?.[0] || null,
          rating: product.rating || 0,
          inStock: product.stock > 0,
        })),
        notifications: notifications.map(notif => ({
          id: notif._id.toString(),
          type: notif.type,
          title: notif.title,
          message: notif.message,
          createdAt: notif.createdAt.toISOString(),
        })),
      };

    } else if (user.role === 'retailer') {
      // Retailer Dashboard
      const [
        totalProducts, 
        lowStockProducts, 
        recentCustomerOrders, 
        wholesaleOrders,
        revenueStats,
        notifications
      ] = await Promise.all([
        Product.countDocuments({ retailerId: user._id, isActive: true }),
        Product.find({ 
          retailerId: user._id, 
          isActive: true, 
          stock: { $gt: 0, $lte: 10 } 
        })
          .select('name stock price')
          .sort({ stock: 1 })
          .limit(10)
          .lean(),
        Order.find({ retailerId: user._id })
          .sort({ createdAt: -1 })
          .limit(10)
          .populate('userId', 'name email')
          .lean(),
        Order.find({ 
          userId: user._id, 
          wholesalerId: { $exists: true, $ne: null } 
        })
          .sort({ createdAt: -1 })
          .limit(10)
          .populate('wholesalerId', 'name businessName')
          .lean(),
        Order.aggregate([
          { $match: { retailerId: user._id } },
          { $group: {
            _id: null,
            totalRevenue: { $sum: '$finalAmount' },
            totalOrders: { $sum: 1 },
            pendingOrders: { 
              $sum: { $cond: [{ $eq: ['$status', 'pending'] }, 1, 0] } 
            },
            completedOrders: { 
              $sum: { $cond: [{ $eq: ['$status', 'delivered'] }, 1, 0] } 
            }
          }}
        ]),
        Notification.find({ userId: user._id, isRead: false })
          .sort({ createdAt: -1 })
          .limit(10)
          .lean()
      ]);

      const productStats = await Product.aggregate([
        { $match: { retailerId: user._id, isActive: true } },
        { $group: {
          _id: null,
          totalProducts: { $sum: 1 },
          inStock: { $sum: { $cond: [{ $gt: ['$stock', 0] }, 1, 0] } },
          outOfStock: { $sum: { $cond: [{ $lte: ['$stock', 0] }, 1, 0] } },
          totalInventoryValue: { $sum: { $multiply: ['$price', '$stock'] } }
        }}
      ]);

      dashboardData = {
        role: 'retailer',
        stats: {
          totalProducts: productStats[0]?.totalProducts || 0,
          inStock: productStats[0]?.inStock || 0,
          outOfStock: productStats[0]?.outOfStock || 0,
          totalInventoryValue: productStats[0]?.totalInventoryValue || 0,
          totalRevenue: revenueStats[0]?.totalRevenue || 0,
          totalOrders: revenueStats[0]?.totalOrders || 0,
          pendingOrders: revenueStats[0]?.pendingOrders || 0,
          completedOrders: revenueStats[0]?.completedOrders || 0,
        },
        lowStockProducts: lowStockProducts.map(product => ({
          id: product._id.toString(),
          name: product.name,
          stock: product.stock,
          price: product.price,
        })),
        recentCustomerOrders: recentCustomerOrders.map(order => ({
          id: order._id.toString(),
          customerName: order.userId?.name || 'Unknown',
          totalAmount: order.finalAmount,
          status: order.status,
          createdAt: order.createdAt.toISOString(),
        })),
        wholesaleOrders: wholesaleOrders.map(order => ({
          id: order._id.toString(),
          wholesalerName: order.wholesalerId?.businessName || order.wholesalerId?.name || 'Unknown',
          totalAmount: order.finalAmount,
          status: order.status,
          createdAt: order.createdAt.toISOString(),
        })),
        notifications: notifications.map(notif => ({
          id: notif._id.toString(),
          type: notif.type,
          title: notif.title,
          message: notif.message,
          createdAt: notif.createdAt.toISOString(),
        })),
      };

    } else if (user.role === 'wholesaler') {
      // Wholesaler Dashboard
      const [
        totalProducts,
        totalRetailers,
        wholesaleOrders,
        topSellingProducts,
        revenueStats,
        notifications
      ] = await Promise.all([
        Product.countDocuments({ wholesalerId: user._id, isActive: true }),
        Order.distinct('userId', { wholesalerId: user._id }),
        Order.find({ wholesalerId: user._id })
          .sort({ createdAt: -1 })
          .limit(10)
          .populate('userId', 'name businessName')
          .lean(),
        Order.aggregate([
          { $match: { wholesalerId: user._id } },
          { $unwind: '$items' },
          { $group: {
            _id: '$items.productId',
            productName: { $first: '$items.productName' },
            totalQuantity: { $sum: '$items.quantity' },
            totalRevenue: { $sum: { $multiply: ['$items.price', '$items.quantity'] } }
          }},
          { $sort: { totalQuantity: -1 } },
          { $limit: 10 }
        ]),
        Order.aggregate([
          { $match: { wholesalerId: user._id } },
          { $group: {
            _id: null,
            totalRevenue: { $sum: '$finalAmount' },
            totalOrders: { $sum: 1 },
            pendingOrders: { 
              $sum: { $cond: [{ $eq: ['$status', 'pending'] }, 1, 0] } 
            },
            completedOrders: { 
              $sum: { $cond: [{ $in: ['$status', ['delivered', 'shipped']] }, 1, 0] } 
            }
          }}
        ]),
        Notification.find({ userId: user._id, isRead: false })
          .sort({ createdAt: -1 })
          .limit(10)
          .lean()
      ]);

      const productStats = await Product.aggregate([
        { $match: { wholesalerId: user._id, isActive: true } },
        { $group: {
          _id: null,
          totalProducts: { $sum: 1 },
          inStock: { $sum: { $cond: [{ $gt: ['$stock', 0] }, 1, 0] } },
          outOfStock: { $sum: { $cond: [{ $lte: ['$stock', 0] }, 1, 0] } },
          totalInventoryValue: { $sum: { $multiply: ['$price', '$stock'] } }
        }}
      ]);

      dashboardData = {
        role: 'wholesaler',
        stats: {
          totalProducts: productStats[0]?.totalProducts || 0,
          inStock: productStats[0]?.inStock || 0,
          outOfStock: productStats[0]?.outOfStock || 0,
          totalInventoryValue: productStats[0]?.totalInventoryValue || 0,
          totalRetailers: totalRetailers.length,
          totalRevenue: revenueStats[0]?.totalRevenue || 0,
          totalOrders: revenueStats[0]?.totalOrders || 0,
          pendingOrders: revenueStats[0]?.pendingOrders || 0,
          completedOrders: revenueStats[0]?.completedOrders || 0,
        },
        topSellingProducts: topSellingProducts.map(product => ({
          id: product._id.toString(),
          name: product.productName,
          totalQuantity: product.totalQuantity,
          totalRevenue: product.totalRevenue,
        })),
        recentOrders: wholesaleOrders.map(order => ({
          id: order._id.toString(),
          retailerName: order.userId?.businessName || order.userId?.name || 'Unknown',
          totalAmount: order.finalAmount,
          status: order.status,
          createdAt: order.createdAt.toISOString(),
        })),
        notifications: notifications.map(notif => ({
          id: notif._id.toString(),
          type: notif.type,
          title: notif.title,
          message: notif.message,
          createdAt: notif.createdAt.toISOString(),
        })),
      };
    }

    res.json(successResponse(dashboardData));
  } catch (error) {
    console.error('Get dashboard error:', error);
    res.status(500).json(errorResponse(createApiError('user', error.message), 'Failed to get dashboard'));
  }
};