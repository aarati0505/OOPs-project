/**
 * Input validation utilities
 * Lightweight validation without heavy dependencies
 */

const { ValidationError } = require('./error.util');

/**
 * Validate email format
 */
function isValidEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

/**
 * Validate phone number (basic check)
 */
function isValidPhone(phone) {
  // Allow digits, +, spaces, hyphens
  const phoneRegex = /^[\d\s\+\-\(\)]+$/;
  return phoneRegex.test(phone) && phone.replace(/\D/g, '').length >= 10;
}

/**
 * Validate signup payload
 */
function validateSignupPayload(body) {
  const { name, email, phoneNumber, password, role } = body;

  if (!name || typeof name !== 'string' || name.trim().length < 2) {
    throw new ValidationError('Name must be at least 2 characters', 'name');
  }

  if (!email || typeof email !== 'string' || !isValidEmail(email)) {
    throw new ValidationError('Valid email is required', 'email');
  }

  if (!phoneNumber || typeof phoneNumber !== 'string' || !isValidPhone(phoneNumber)) {
    throw new ValidationError('Valid phone number is required', 'phoneNumber');
  }

  if (!password || typeof password !== 'string' || password.length < 6) {
    throw new ValidationError('Password must be at least 6 characters', 'password');
  }

  const allowedRoles = ['customer', 'retailer', 'wholesaler'];
  if (role && !allowedRoles.includes(role)) {
    throw new ValidationError(`Role must be one of: ${allowedRoles.join(', ')}`, 'role');
  }

  return true;
}

/**
 * Validate login payload
 */
function validateLoginPayload(body) {
  const { emailOrPhone, password } = body;

  if (!emailOrPhone || typeof emailOrPhone !== 'string' || emailOrPhone.trim().length === 0) {
    throw new ValidationError('Email or phone is required', 'emailOrPhone');
  }

  if (!password || typeof password !== 'string' || password.length === 0) {
    throw new ValidationError('Password is required', 'password');
  }

  return true;
}

/**
 * Validate product payload (for create/update)
 */
function validateProductPayload(body, isUpdate = false) {
  const { name, price, stock, categoryId, stockQuantity } = body;

  if (!isUpdate) {
    if (!name || typeof name !== 'string' || name.trim().length < 2) {
      throw new ValidationError('Product name must be at least 2 characters', 'name');
    }

    if (!categoryId) {
      throw new ValidationError('Category ID is required', 'categoryId');
    }
  } else {
    if (name !== undefined && (typeof name !== 'string' || name.trim().length < 2)) {
      throw new ValidationError('Product name must be at least 2 characters', 'name');
    }
  }

  // Price validation
  if (price !== undefined) {
    const priceNum = parseFloat(price);
    if (isNaN(priceNum) || priceNum < 0) {
      throw new ValidationError('Price must be a non-negative number', 'price');
    }
  } else if (!isUpdate) {
    throw new ValidationError('Price is required', 'price');
  }

  // Stock validation (support both 'stock' and 'stockQuantity')
  const stockValue = stock !== undefined ? stock : stockQuantity;
  if (stockValue !== undefined) {
    const stockNum = parseInt(stockValue);
    if (isNaN(stockNum) || stockNum < 0) {
      throw new ValidationError('Stock must be a non-negative integer', 'stock');
    }
  } else if (!isUpdate) {
    throw new ValidationError('Stock is required', 'stock');
  }

  return true;
}

/**
 * Validate cart item payload
 */
function validateCartItemPayload(body) {
  const { productId, quantity } = body;

  if (!productId || typeof productId !== 'string') {
    throw new ValidationError('Product ID is required', 'productId');
  }

  const qty = parseInt(quantity);
  if (isNaN(qty) || qty < 1) {
    throw new ValidationError('Quantity must be at least 1', 'quantity');
  }

  return true;
}

/**
 * Validate order payload (customer order)
 */
function validateOrderPayload(body) {
  const { items, paymentMethod } = body;

  if (!items || !Array.isArray(items) || items.length === 0) {
    throw new ValidationError('Order must contain at least one item', 'items');
  }

  // Validate each item
  items.forEach((item, index) => {
    if (!item.productId || typeof item.productId !== 'string') {
      throw new ValidationError(`Item ${index + 1}: Product ID is required`, `items[${index}].productId`);
    }

    const qty = parseInt(item.quantity);
    if (isNaN(qty) || qty < 1) {
      throw new ValidationError(`Item ${index + 1}: Quantity must be at least 1`, `items[${index}].quantity`);
    }
  });

  const allowedPaymentMethods = ['card', 'cash_on_delivery', 'paypal', 'wallet'];
  if (paymentMethod && !allowedPaymentMethods.includes(paymentMethod)) {
    throw new ValidationError(`Payment method must be one of: ${allowedPaymentMethods.join(', ')}`, 'paymentMethod');
  }

  return true;
}

/**
 * Validate wholesale order payload
 */
function validateWholesaleOrderPayload(body) {
  const { items, paymentMethod } = body;

  if (!items || !Array.isArray(items) || items.length === 0) {
    throw new ValidationError('Wholesale order must contain at least one item', 'items');
  }

  // Validate each item
  items.forEach((item, index) => {
    if (!item.productId || typeof item.productId !== 'string') {
      throw new ValidationError(`Item ${index + 1}: Product ID is required`, `items[${index}].productId`);
    }

    const qty = parseInt(item.quantity);
    if (isNaN(qty) || qty < 1) {
      throw new ValidationError(`Item ${index + 1}: Quantity must be at least 1`, `items[${index}].quantity`);
    }
  });

  const allowedPaymentMethods = ['card', 'cash_on_delivery', 'paypal', 'wallet'];
  if (paymentMethod && !allowedPaymentMethods.includes(paymentMethod)) {
    throw new ValidationError(`Payment method must be one of: ${allowedPaymentMethods.join(', ')}`, 'paymentMethod');
  }

  return true;
}

/**
 * Validate stock update payload
 */
function validateStockUpdatePayload(body) {
  const { quantity, operation } = body;

  if (quantity === undefined || quantity === null) {
    throw new ValidationError('Quantity is required', 'quantity');
  }

  const qty = parseInt(quantity);
  if (isNaN(qty) || qty < 0) {
    throw new ValidationError('Quantity must be a non-negative integer', 'quantity');
  }

  const allowedOperations = ['add', 'subtract', 'set'];
  if (!operation || !allowedOperations.includes(operation)) {
    throw new ValidationError(`Operation must be one of: ${allowedOperations.join(', ')}`, 'operation');
  }

  return true;
}

/**
 * Validate review payload
 */
function validateReviewPayload(body) {
  const { productId, rating, comment } = body;

  if (!productId || typeof productId !== 'string') {
    throw new ValidationError('Product ID is required', 'productId');
  }

  const ratingNum = parseFloat(rating);
  if (isNaN(ratingNum) || ratingNum < 1 || ratingNum > 5) {
    throw new ValidationError('Rating must be between 1 and 5', 'rating');
  }

  if (!comment || typeof comment !== 'string' || comment.trim().length < 3) {
    throw new ValidationError('Comment must be at least 3 characters', 'comment');
  }

  return true;
}

/**
 * Validate import from wholesaler payload
 */
function validateImportWholesalerPayload(body) {
  const { productId, stock, price } = body;

  if (!productId || typeof productId !== 'string') {
    throw new ValidationError('Product ID is required', 'productId');
  }

  if (stock !== undefined) {
    const stockNum = parseInt(stock);
    if (isNaN(stockNum) || stockNum < 0) {
      throw new ValidationError('Stock must be a non-negative integer', 'stock');
    }
  }

  if (price !== undefined) {
    const priceNum = parseFloat(price);
    if (isNaN(priceNum) || priceNum < 0) {
      throw new ValidationError('Price must be a non-negative number', 'price');
    }
  }

  return true;
}

module.exports = {
  validateSignupPayload,
  validateLoginPayload,
  validateProductPayload,
  validateCartItemPayload,
  validateOrderPayload,
  validateWholesaleOrderPayload,
  validateStockUpdatePayload,
  validateReviewPayload,
  validateImportWholesalerPayload,
  isValidEmail,
  isValidPhone,
};

