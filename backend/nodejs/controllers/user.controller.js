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
