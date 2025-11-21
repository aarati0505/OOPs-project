const Cart = require('../models/Cart');
const Product = require('../models/Product');
const { successResponse, errorResponse, createApiError } = require('../utils/response.util');

/**
 * Cart Controller
 * Matching Dart CartApiService methods
 */

/**
 * Helper function to calculate cart totals
 */
async function calculateCartTotals(items) {
  let subtotal = 0;
  let itemCount = 0;

  for (const item of items) {
    const product = await Product.findById(item.productId).lean();
    if (product && product.isActive) {
      const itemPrice = product.price * item.quantity;
      subtotal += itemPrice;
      itemCount += item.quantity;
    }
  }

  return { subtotal, itemCount, total: subtotal, discount: 0 };
}

/**
 * GET /cart
 * Get cart
 * Matching: CartApiService.getCart()
 */
exports.getCart = async (req, res) => {
  try {
    let cart = await Cart.findOne({ userId: req.user._id }).populate('items.productId');

    if (!cart) {
      cart = new Cart({ userId: req.user._id, items: [] });
      await cart.save();
    }

    // Calculate totals
    const { subtotal, itemCount, total, discount } = await calculateCartTotals(cart.items);

    // Format items (matching Dart CartItem structure)
    const itemsResponse = await Promise.all(
      cart.items.map(async (item) => {
        const product = await Product.findById(item.productId).lean();
        if (!product) return null;

        return {
          id: item._id.toString(),
          productId: product._id.toString(),
          productName: product.name,
          productImage: product.images?.[0] || null,
          quantity: item.quantity,
          unitPrice: product.price,
          totalPrice: product.price * item.quantity,
          weight: product.weight,
        };
      })
    );

    const validItems = itemsResponse.filter(item => item !== null);

    const cartResponse = {
      items: validItems,
      subtotal,
      discount,
      total,
      itemCount,
    };

    res.json(successResponse(cartResponse));
  } catch (error) {
    console.error('Get cart error:', error);
    res.status(500).json(errorResponse(createApiError('cart', error.message), 'Failed to get cart'));
  }
};

/**
 * POST /cart/items
 * Add item to cart
 * Matching: CartApiService.addToCart()
 */
exports.addToCart = async (req, res) => {
  try {
    const { productId, quantity } = req.body;

    if (!productId || !quantity || quantity < 1) {
      return res.status(400).json(
        errorResponse(
          [createApiError('cart', 'Product ID and quantity (>=1) are required')],
          'Validation error'
        )
      );
    }

    // Verify product exists and is active
    const product = await Product.findById(productId);
    if (!product || !product.isActive) {
      return res.status(404).json(
        errorResponse(
          [createApiError('cart', 'Product not found')],
          'Product not found'
        )
      );
    }

    if (product.stock < quantity) {
      return res.status(400).json(
        errorResponse(
          [createApiError('cart', 'Insufficient stock')],
          'Insufficient stock available'
        )
      );
    }

    // Get or create cart
    let cart = await Cart.findOne({ userId: req.user._id });
    if (!cart) {
      cart = new Cart({ userId: req.user._id, items: [] });
    }

    // Check if item already exists in cart
    const existingItemIndex = cart.items.findIndex(
      item => item.productId.toString() === productId
    );

    if (existingItemIndex >= 0) {
      // Update quantity
      cart.items[existingItemIndex].quantity += quantity;
    } else {
      // Add new item
      cart.items.push({ productId, quantity });
    }

    await cart.save();

    // Calculate totals
    const { subtotal, itemCount, total, discount } = await calculateCartTotals(cart.items);

    // Format response
    const itemsResponse = await Promise.all(
      cart.items.map(async (item) => {
        const prod = await Product.findById(item.productId).lean();
        return {
          id: item._id.toString(),
          productId: prod._id.toString(),
          productName: prod.name,
          productImage: prod.images?.[0] || null,
          quantity: item.quantity,
          unitPrice: prod.price,
          totalPrice: prod.price * item.quantity,
          weight: prod.weight,
        };
      })
    );

    const cartResponse = {
      items: itemsResponse,
      subtotal,
      discount,
      total,
      itemCount,
    };

    res.json(successResponse(cartResponse, 'Item added to cart'));
  } catch (error) {
    console.error('Add to cart error:', error);
    res.status(500).json(errorResponse(createApiError('cart', error.message), 'Failed to add item to cart'));
  }
};

/**
 * PUT /cart/items/:itemId
 * Update cart item quantity
 * Matching: CartApiService.updateCartItem()
 */
exports.updateCartItem = async (req, res) => {
  try {
    const { itemId } = req.params;
    const { quantity } = req.body;

    if (!quantity || quantity < 1) {
      return res.status(400).json(
        errorResponse(
          [createApiError('cart', 'Quantity must be at least 1')],
          'Validation error'
        )
      );
    }

    const cart = await Cart.findOne({ userId: req.user._id });
    if (!cart) {
      return res.status(404).json(
        errorResponse(
          [createApiError('cart', 'Cart not found')],
          'Cart not found'
        )
      );
    }

    const item = cart.items.id(itemId);
    if (!item) {
      return res.status(404).json(
        errorResponse(
          [createApiError('cart', 'Cart item not found')],
          'Cart item not found'
        )
      );
    }

    // Check stock
    const product = await Product.findById(item.productId);
    if (!product || product.stock < quantity) {
      return res.status(400).json(
        errorResponse(
          [createApiError('cart', 'Insufficient stock')],
          'Insufficient stock available'
        )
      );
    }

    item.quantity = quantity;
    await cart.save();

    // Calculate totals
    const { subtotal, itemCount, total, discount } = await calculateCartTotals(cart.items);

    const itemsResponse = await Promise.all(
      cart.items.map(async (cartItem) => {
        const prod = await Product.findById(cartItem.productId).lean();
        return {
          id: cartItem._id.toString(),
          productId: prod._id.toString(),
          productName: prod.name,
          productImage: prod.images?.[0] || null,
          quantity: cartItem.quantity,
          unitPrice: prod.price,
          totalPrice: prod.price * cartItem.quantity,
          weight: prod.weight,
        };
      })
    );

    const cartResponse = {
      items: itemsResponse,
      subtotal,
      discount,
      total,
      itemCount,
    };

    res.json(successResponse(cartResponse, 'Cart item updated'));
  } catch (error) {
    console.error('Update cart item error:', error);
    res.status(500).json(errorResponse(createApiError('cart', error.message), 'Failed to update cart item'));
  }
};

/**
 * DELETE /cart/items/:itemId
 * Remove item from cart
 * Matching: CartApiService.removeFromCart()
 */
exports.removeFromCart = async (req, res) => {
  try {
    const { itemId } = req.params;

    const cart = await Cart.findOne({ userId: req.user._id });
    if (!cart) {
      return res.status(404).json(
        errorResponse(
          [createApiError('cart', 'Cart not found')],
          'Cart not found'
        )
      );
    }

    cart.items.id(itemId)?.remove();
    await cart.save();

    // Calculate totals
    const { subtotal, itemCount, total, discount } = await calculateCartTotals(cart.items);

    const itemsResponse = await Promise.all(
      cart.items.map(async (item) => {
        const product = await Product.findById(item.productId).lean();
        return {
          id: item._id.toString(),
          productId: product._id.toString(),
          productName: product.name,
          productImage: product.images?.[0] || null,
          quantity: item.quantity,
          unitPrice: product.price,
          totalPrice: product.price * item.quantity,
          weight: product.weight,
        };
      })
    );

    const cartResponse = {
      items: itemsResponse,
      subtotal,
      discount,
      total,
      itemCount,
    };

    res.json(successResponse(cartResponse, 'Item removed from cart'));
  } catch (error) {
    console.error('Remove from cart error:', error);
    res.status(500).json(errorResponse(createApiError('cart', error.message), 'Failed to remove item from cart'));
  }
};

/**
 * POST /cart/clear
 * Clear cart
 * Matching: CartApiService.clearCart()
 */
exports.clearCart = async (req, res) => {
  try {
    const cart = await Cart.findOne({ userId: req.user._id });
    if (cart) {
      cart.items = [];
      await cart.save();
    }

    res.json(successResponse(null, 'Cart cleared'));
  } catch (error) {
    console.error('Clear cart error:', error);
    res.status(500).json(errorResponse(createApiError('cart', error.message), 'Failed to clear cart'));
  }
};
