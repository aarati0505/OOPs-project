# Python Flask Authentication Routes
# These endpoints match: lib/core/constants/app_constants.dart

from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, create_refresh_token
from models.user import User
from utils.password import verify_password, hash_password

bp = Blueprint('auth', __name__)

@bp.route('/login', methods=['POST'])
def login():
    """
    POST /v1/auth/login
    Matches: AuthApiService.login()
    Request: { "emailOrPhone": "...", "password": "..." }
    Response: { "success": true, "data": { "user": {...}, "accessToken": "..." } }
    """
    data = request.get_json()
    email_or_phone = data.get('emailOrPhone')
    password = data.get('password')

    # Find user by email or phone
    user = User.find_by_email_or_phone(email_or_phone)

    if not user or not verify_password(password, user.password):
        return jsonify({
            'success': False,
            'message': 'Invalid credentials'
        }), 401

    # Generate tokens
    access_token = create_access_token(identity=str(user.id), additional_claims={'role': user.role})
    refresh_token = create_refresh_token(identity=str(user.id))

    # Update last login
    user.update_last_login()

    return jsonify({
        'success': True,
        'message': 'Login successful',
        'data': {
            'user': user.to_dict(),
            'accessToken': access_token,
            'refreshToken': refresh_token
        }
    }), 200

@bp.route('/signup', methods=['POST'])
def signup():
    """
    POST /v1/auth/signup
    Matches: AuthApiService.signup()
    """
    data = request.get_json()
    
    # Create user
    user = User.create(
        name=data.get('name'),
        email=data.get('email'),
        phone_number=data.get('phoneNumber'),
        password=data.get('password'),
        role=data.get('role'),
        business_name=data.get('businessName'),
        business_address=data.get('businessAddress'),
        location=data.get('location')
    )

    if not user:
        return jsonify({
            'success': False,
            'message': 'User already exists'
        }), 400

    # Generate tokens
    access_token = create_access_token(identity=str(user.id), additional_claims={'role': user.role})
    refresh_token = create_refresh_token(identity=str(user.id))

    return jsonify({
        'success': True,
        'message': 'Signup successful',
        'data': {
            'user': user.to_dict(),
            'accessToken': access_token,
            'refreshToken': refresh_token
        }
    }), 201

@bp.route('/verify-otp', methods=['POST'])
def verify_otp():
    """POST /v1/auth/verify-otp"""
    # Implementation here
    pass

@bp.route('/forgot-password', methods=['POST'])
def forgot_password():
    """POST /v1/auth/forgot-password"""
    # Implementation here
    pass

@bp.route('/reset-password', methods=['POST'])
def reset_password():
    """POST /v1/auth/reset-password"""
    # Implementation here
    pass

@bp.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    """POST /v1/auth/logout"""
    return jsonify({
        'success': True,
        'message': 'Logged out successfully'
    }), 200

@bp.route('/refresh', methods=['POST'])
def refresh():
    """POST /v1/auth/refresh"""
    # Implementation here
    pass

