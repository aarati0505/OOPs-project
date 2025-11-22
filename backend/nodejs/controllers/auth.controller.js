const User = require('../models/User');
const OtpToken = require('../models/OtpToken');
const { successResponse, errorResponse, createApiError } = require('../utils/response.util');
const { validateSignupPayload, validateLoginPayload } = require('../utils/validation.util');
const { ValidationError, NotFoundError, UnauthorizedError } = require('../utils/error.util');
const {
  hashPassword,
  comparePassword,
  generateAccessToken,
  generateRefreshToken,
  verifyToken,
  generateOtpCode,
  hashOtpCode,
  verifyOtpCode,
} = require('../services/auth.service');
const { resolveUserLocation } = require('../services/location.service');

const ALLOWED_ROLES = ['customer', 'retailer', 'wholesaler'];
const OTP_EXPIRY_MINUTES = parseInt(process.env.OTP_EXPIRY_MINUTES || '10', 10);

/**
 * Authentication Controller
 * Matching Dart AuthApiService methods
 */

/**
 * POST /auth/login
 * Login with email/phone and password
 * Matching: AuthApiService.login()
 */
exports.login = async (req, res, next) => {
  try {
    // Validate login payload
    validateLoginPayload(req.body);

    const { emailOrPhone, password } = req.body;

    // Find user by email or phone
    const user = await User.findOne({
      $or: [
        { email: emailOrPhone.toLowerCase() },
        { phone: emailOrPhone },
      ],
    });

    if (!user) {
      throw new UnauthorizedError('Invalid credentials');
    }

    // Verify password
    const isPasswordValid = await comparePassword(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedError('Invalid credentials');
    }

    // Update last login
    user.lastLoginAt = new Date();
    await user.save();

    const tokens = await issueAuthTokens(user);
    res.json(successResponse(tokens, 'Login successful'));
  } catch (error) {
    next(error);
  }
};

/**
 * POST /auth/signup
 * Sign up new user
 * Matching: AuthApiService.signup()
 */
exports.signup = async (req, res, next) => {
  try {
    // Validate signup payload
    validateSignupPayload(req.body);

    const {
      name,
      email,
      phoneNumber,
      password,
      role = 'customer',
      businessName,
      businessAddress,
      locationInput,
      location,
    } = req.body;

    if (!name || !email || !phoneNumber || !password) {
      return res.status(400).json(errorResponse(
        [createApiError('auth', 'Name, email, phone, and password are required')],
        'Validation error',
      ));
    }

    if (!ALLOWED_ROLES.includes(role)) {
      return res.status(400).json(errorResponse(
        [createApiError('auth', 'Invalid role')],
        'Validation error',
      ));
    }

    const existingUser = await User.findOne({
      $or: [{ email: email.toLowerCase() }, { phone: phoneNumber }],
    });

    if (existingUser) {
      return res.status(409).json(errorResponse(
        [createApiError('auth', 'User already exists with this email or phone')],
        'Signup failed',
      ));
    }

    const passwordHash = await hashPassword(password);

    let normalizedLocation = null;
    const rawLocation = locationInput || location;
    if (rawLocation) {
      normalizedLocation = await resolveUserLocation(rawLocation);
    }

    const user = new User({
      name,
      email: email.toLowerCase(),
      phone: phoneNumber,
      passwordHash,
      role,
      isEmailVerified: false,
      isPhoneVerified: false,
      businessName,
      businessAddress,
      location: normalizedLocation,
    });
    await user.save();

    const tokens = await issueAuthTokens(user);

    res.json(successResponse(tokens, 'Signup successful'));
  } catch (error) {
    console.error('Signup error:', error);
    if (error.code === 11000) {
      return res.status(409).json(
        errorResponse(
          [createApiError('auth', 'User already exists')],
          'Signup failed'
        )
      );
    }
    res.status(500).json(errorResponse(createApiError('auth', error.message), 'Signup failed'));
  }
};

/**
 * POST /auth/verify-otp
 * Verify OTP for phone number
 * Matching: AuthApiService.verifyOtp()
 */
exports.verifyOtp = async (req, res, next) => {
  try {
    const { 
      phoneNumber, 
      otp, 
      role = 'customer', 
      name, 
      email,
      password,
      businessName,
      businessAddress,
    } = req.body;

    if (!phoneNumber || !otp) {
      throw new ValidationError('Phone number and OTP are required');
    }

    const otpToken = await OtpToken.findOne({ phoneNumber }).sort({ createdAt: -1 });
    if (!otpToken) {
      throw new ValidationError('OTP not requested or expired');
    }

    if (otpToken.expiresAt < new Date()) {
      await OtpToken.deleteMany({ phoneNumber });
      throw new ValidationError('OTP expired');
    }

    const isValidOtp = await verifyOtpCode(otp, otpToken.otpHash);
    if (!isValidOtp) {
      throw new ValidationError('Invalid OTP');
    }

    await OtpToken.deleteMany({ phoneNumber });

    // Check if user already exists
    let user = await User.findOne({ phone: phoneNumber });
    
    if (!user) {
      // Create new user with signup data
      if (!name || !email || !password) {
        throw new ValidationError('Name, email, and password are required for signup');
      }

      const assignedRole = ALLOWED_ROLES.includes(role) ? role : 'customer';
      const passwordHash = await hashPassword(password);
      
      user = new User({
        name,
        email: email.toLowerCase(),
        phone: phoneNumber,
        passwordHash,
        role: assignedRole,
        businessName,
        businessAddress,
        isPhoneVerified: true,
        isEmailVerified: false, // Will be verified when they verify email
      });
      await user.save();
    } else {
      // User exists, just mark phone as verified
      user.isPhoneVerified = true;
      // Update role if provided and different
      if (role && ALLOWED_ROLES.includes(role) && user.role !== role) {
        user.role = role;
      }
      // Update other fields if provided
      if (name) user.name = name;
      if (email) user.email = email.toLowerCase();
      if (businessName) user.businessName = businessName;
      if (businessAddress) user.businessAddress = businessAddress;
      await user.save();
    }

    const tokens = await issueAuthTokens(user);
    res.json(successResponse(tokens, 'OTP verified successfully'));
  } catch (error) {
    next(error);
  }
};

/**
 * POST /auth/forgot-password
 * Request password reset
 * Matching: AuthApiService.forgotPassword()
 */
exports.forgotPassword = async (req, res) => {
  try {
    const { emailOrPhone } = req.body;

    if (!emailOrPhone) {
      return res.status(400).json(
        errorResponse(
          [createApiError('auth', 'Email or phone is required')],
          'Validation error'
        )
      );
    }

    const user = await User.findOne({
      $or: [
        { email: emailOrPhone.toLowerCase() },
        { phone: emailOrPhone },
      ],
    });

    if (!user) {
      // Don't reveal if user exists for security
      return res.json(successResponse(null, 'If the account exists, a password reset email has been sent'));
    }

    // TODO: Generate reset token and send email/SMS
    // For now, just return success

    res.json(successResponse(null, 'Password reset email sent'));
  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json(errorResponse(createApiError('auth', error.message), 'Failed to send reset email'));
  }
};

/**
 * POST /auth/reset-password
 * Reset password with token
 * Matching: AuthApiService.resetPassword()
 */
exports.resetPassword = async (req, res) => {
  try {
    const { token, newPassword } = req.body;

    if (!token || !newPassword) {
      return res.status(400).json(
        errorResponse(
          [createApiError('auth', 'Token and new password are required')],
          'Validation error'
        )
      );
    }

    // TODO: Verify reset token (from cache/DB)
    // For now, decode token to get user ID (if using JWT for reset)
    // In production, use a separate reset token system

    res.json(successResponse(null, 'Password reset successful'));
  } catch (error) {
    console.error('Reset password error:', error);
    res.status(500).json(errorResponse(createApiError('auth', error.message), 'Password reset failed'));
  }
};

/**
 * POST /auth/logout
 * Logout user
 * Matching: AuthApiService.logout()
 */
exports.logout = async (req, res) => {
  try {
    // Clear refresh token (stateless approach)
    if (req.user) {
      await User.findByIdAndUpdate(req.user._id, { $unset: { refreshToken: 1 } });
    }

    res.json(successResponse(null, 'Logout successful'));
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json(errorResponse(createApiError('auth', error.message), 'Logout failed'));
  }
};

/**
 * POST /auth/refresh
 * Refresh access token
 * Matching: AuthApiService.refreshToken()
 */
exports.refreshToken = async (req, res) => {
  try {
    const { refreshToken: token } = req.body;

    if (!token) {
      return res.status(400).json(
        errorResponse(
          [createApiError('auth', 'Refresh token is required')],
          'Validation error'
        )
      );
    }

    // Verify refresh token
    const decoded = await verifyToken(token);

    // Find user and verify refresh token matches
    const user = await User.findById(decoded.userId);
    if (!user || user.refreshToken !== token) {
      return res.status(401).json(
        errorResponse(
          [createApiError('auth', 'Invalid refresh token')],
          'Token refresh failed'
        )
      );
    }

    const accessToken = generateAccessToken(user);
    const newRefreshToken = generateRefreshToken(user);

    user.refreshToken = newRefreshToken;
    await user.save();

    res.json(successResponse({
      accessToken,
      refreshToken: newRefreshToken,
    }, 'Token refreshed successfully'));
  } catch (error) {
    console.error('Refresh token error:', error);
    res.status(401).json(errorResponse(createApiError('auth', error.message), 'Token refresh failed'));
  }
};

exports.requestOtp = async (req, res) => {
  try {
    const { phoneNumber, purpose = 'login' } = req.body;

    if (!phoneNumber) {
      return res.status(400).json(errorResponse(
        [createApiError('auth', 'Phone number is required')],
        'Validation error',
      ));
    }

    const otpCode = generateOtpCode();
    const otpHash = await hashOtpCode(otpCode);
    const expiresAt = new Date(Date.now() + OTP_EXPIRY_MINUTES * 60 * 1000);

    await OtpToken.create({
      phoneNumber,
      otpHash,
      purpose,
      expiresAt,
    });

    // OTP sent (masked in logs for security)
    if (process.env.NODE_ENV !== 'production') {
      console.log(`OTP requested for ${phoneNumber}`); // Don't log actual OTP code
    }

    res.json(successResponse(
      { phoneNumber },
      'OTP sent successfully',
      { devOtp: otpCode, expiresAt },
    ));
  } catch (error) {
    console.error('Request OTP error:', error);
    res.status(500).json(errorResponse(createApiError('auth', error.message), 'Failed to send OTP'));
  }
};

exports.loginWithGoogle = async (req, res) => {
  try {
    const { idToken } = req.body;
    if (!idToken) {
      return res.status(400).json(errorResponse(
        [createApiError('auth', 'Google ID token is required')],
        'Validation error',
      ));
    }

    // TODO: Replace with real Google token verification
    const profile = mockSocialVerification(idToken, 'google');
    let user = await User.findOne({ email: profile.email });

    if (!user) {
      const placeholderPassword = await hashPassword(`google-${Date.now()}`);
      user = new User({
        name: profile.name,
        email: profile.email,
        phone: profile.phone || `+google_${Date.now()}`,
        passwordHash: placeholderPassword,
        role: 'customer',
        isEmailVerified: true,
      });
      await user.save();
    }

    const tokens = await issueAuthTokens(user);
    res.json(successResponse(tokens, 'Google login successful'));
  } catch (error) {
    console.error('Google login error:', error);
    res.status(500).json(errorResponse(createApiError('auth', error.message), 'Google login failed'));
  }
};

exports.loginWithFacebook = async (req, res) => {
  try {
    const { idToken } = req.body;
    if (!idToken) {
      return res.status(400).json(errorResponse(
        [createApiError('auth', 'Facebook token is required')],
        'Validation error',
      ));
    }

    // TODO: Replace with real Facebook token verification
    const profile = mockSocialVerification(idToken, 'facebook');
    let user = await User.findOne({ email: profile.email });

    if (!user) {
      const placeholderPassword = await hashPassword(`facebook-${Date.now()}`);
      user = new User({
        name: profile.name,
        email: profile.email,
        phone: profile.phone || `+fb_${Date.now()}`,
        passwordHash: placeholderPassword,
        role: 'customer',
        isEmailVerified: true,
      });
      await user.save();
    }

    const tokens = await issueAuthTokens(user);
    res.json(successResponse(tokens, 'Facebook login successful'));
  } catch (error) {
    console.error('Facebook login error:', error);
    res.status(500).json(errorResponse(createApiError('auth', error.message), 'Facebook login failed'));
  }
};

async function issueAuthTokens(user) {
  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);
  user.refreshToken = refreshToken;
  await user.save();

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
    location: user.location,
    businessName: user.businessName,
    businessAddress: user.businessAddress,
  };

  return {
    user: userResponse,
    accessToken,
    refreshToken,
  };
}

function mockSocialVerification(idToken, provider) {
  // TODO: Replace with real provider verification (Google/Facebook SDKs)
  return {
    name: provider === 'google' ? 'Google User' : 'Facebook User',
    email: `${provider}_${idToken.slice(0, 6)}@example.com`,
    phone: null,
  };
}
