const Order = require('../models/Order');
const Cart = require('../models/Cart');
const Product = require('../models/Product');
const Address = require('../models/Address');
const Notification = require('../models/Notification');
const { successResponse, errorResponse, createApiError } = require('../utils/response.util');
const { parsePagination, calculatePagination } = require('../utils/pagination.util');

/**
 * Order Controller
 * Matching Dart OrderApiService methods
 */

/**
 * POST /orders
 * Create order (Customer)
 * Matching: OrderApiService.createOrder()
 */
exports.createOrder = async (req, res) => {
  try {
    const user = req.user;
    if (user.role !== 'customer') {
      return res.status(403).json(
        errorResponse(
          [createApiError('order', 'Only customers can create orders')],
          'Access denied'
        )
      );
    }

    const { items, deliveryAddressId, scheduledDeliveryDate, deliveryInstructions, paymentMethod, couponCode } = req.body;

    // If items not provided, use cart
    let orderItems = items;
    if (!orderItems || orderItems.length === 0) {
      const cart = await Cart.findOne({ userId: user._id }).populate('items.productId');
      if (!cart || cart.items.length === 0) {
        return res.status(400).json(
          errorResponse(
            [createApiError('order', 'Cart is empty')],
            'Cannot create order with empty cart'
          )
        );
      }
      orderItems = cart.items.map(item => ({
        productId: item.productId._id.toString(),
        quantity: item.quantity,
      }));
    }

    // Validate and fetch products
    const productIds = orderItems.map(item => item.productId);
    const products = await Product.find({ _id: { $in: productIds }, isActive: true });

    if (products.length !== productIds.length) {
      return res.status(400).json(
        errorResponse(
          [createApiError('order', 'Some products are not available')],
          'Invalid products in order'
        )
      );
    }

    // Build order items with product details
    let totalAmount = 0;
    const orderItemsData = [];

    for (const item of orderItems) {
      const product = products.find(p => p._id.toString() === item.productId);
      if (!product) continue;

      if (product.stock < item.quantity) {
        return res.status(400).json(
          errorResponse(
            [createApiError('order', `Insufficient stock for ${product.name}`)],
            'Insufficient stock'
          )
        );
      }

      const itemPrice = product.price * item.quantity;
      totalAmount += itemPrice;

      orderItemsData.push({
        productId: product._id,
        quantity: item.quantity,
        price: product.price,
        productName: product.name,
        productImage: product.images?.[0] || null,
      });
    }

    // Get delivery address
    let deliveryAddress = null;
    if (deliveryAddressId) {
      const address = await Address.findOne({ _id: deliveryAddressId, userId: user._id });
      if (address) {
        deliveryAddress = {
          label: address.label,
          line1: address.line1,
          line2: address.line2,
          city: address.city,
          region: address.region,
          pincode: address.pincode,
          lat: address.lat,
          lng: address.lng,
        };
      }
    }

    // Determine retailer/wholesaler from products
    const retailerIds = new Set();
    const wholesalerIds = new Set();
    products.forEach(product => {
      if (product.retailerId) retailerIds.add(product.retailerId);
      if (product.wholesalerId) wholesalerIds.add(product.wholesalerId);
    });

    // Create order
    const orderData = {
      userId: user._id,
      retailerId: retailerIds.size === 1 ? Array.from(retailerIds)[0] : null,
      wholesalerId: wholesalerIds.size === 1 ? Array.from(wholesalerIds)[0] : null,
      items: orderItemsData,
      totalAmount,
      finalAmount: totalAmount, // TODO: Apply coupon discount
      status: 'pending',
      paymentMethod: paymentMethod || 'cash_on_delivery',
      paymentStatus: paymentMethod === 'cash_on_delivery' ? 'pending' : 'pending',
      deliveryAddressId: deliveryAddressId || null,
      deliveryAddress: deliveryAddress,
      scheduledDeliveryDate: scheduledDeliveryDate ? new Date(scheduledDeliveryDate) : null,
      deliveryInstructions,
      couponCode,
      trackingInfo: [{
        status: 'pending',
        message: 'Order placed',
        timestamp: new Date(),
      }],
    };

    const order = new Order(orderData);
    await order.save();

    // Update product stock
    for (const item of orderItemsData) {
      await Product.findByIdAndUpdate(item.productId, {
        $inc: { stock: -item.quantity },
      });
    }

    // Clear cart if order was created from cart
    if (!items || items.length === 0) {
      await Cart.findOneAndUpdate({ userId: user._id }, { items: [] });
    }

    // Create notifications
    if (order.retailerId) {
      await Notification.create({
        userId: order.retailerId,
        type: 'order',
        title: 'New Order',
        message: `You have a new order #${order._id.toString().slice(-6)}`,
        data: { orderId: order._id.toString() },
      });
    }

    await order.populate('userId', 'name email');
    await order.populate('retailerId', 'name businessName');
    await order.populate('wholesalerId', 'name businessName');

    // Format response (matching Dart OrderModel)
    const orderResponse = {
      id: order._id.toString(),
      userId: order.userId._id.toString(),
      userRole: 'customer',
      items: order.items.map(item => ({
        productId: item.productId.toString(),
        quantity: item.quantity,
        price: item.price,
        productName: item.productName,
        totalPrice: item.price * item.quantity,
      })),
      totalAmount: order.totalAmount,
      finalAmount: order.finalAmount,
      paymentMethod: order.paymentMethod,
      deliveryAddress: order.deliveryAddress,
      scheduledDeliveryDate: order.scheduledDeliveryDate?.toISOString(),
      deliveryInstructions: order.deliveryInstructions,
      status: order.status,
      createdAt: order.createdAt.toISOString(),
      updatedAt: order.updatedAt.toISOString(),
    };

    res.json(successResponse(orderResponse, 'Order created successfully'));
  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json(errorResponse(createApiError('order', error.message), 'Failed to create order'));
  }
};

/**
 * GET /orders
 * Get customer orders
 * Matching: OrderApiService.getCustomerOrders()
 */
exports.getCustomerOrders = async (req, res) => {
  try {
    const user = req.user;
    const pagination = parsePagination(req.query);
    const { status } = req.query;

    const query = { userId: user._id };
    if (status) {
      query.status = status;
    }

    const [orders, totalItems] = await Promise.all([
      Order.find(query)
        .populate('items.productId', 'name images')
        .sort({ placedAt: -1 })
        .skip(pagination.skip)
        .limit(pagination.limit)
        .lean(),
      Order.countDocuments(query),
    ]);

    const ordersResponse = orders.map(order => ({
      id: order._id.toString(),
      userId: order.userId.toString(),
      userRole: 'customer',
      items: order.items.map(item => ({
        productId: item.productId?._id.toString() || item.productId.toString(),
        quantity: item.quantity,
        price: item.price,
        productName: item.productName,
        totalPrice: item.price * item.quantity,
      })),
      totalAmount: order.totalAmount,
      finalAmount: order.finalAmount,
      paymentMethod: order.paymentMethod,
      status: order.status,
      createdAt: order.createdAt.toISOString(),
    }));

    const paginationMeta = calculatePagination(totalItems, pagination.page, pagination.pageSize);

    res.json(successResponse({
      data: ordersResponse,
      ...paginationMeta,
    }));
  } catch (error) {
    console.error('Get customer orders error:', error);
    res.status(500).json(errorResponse(createApiError('order', error.message), 'Failed to get orders'));
  }
};

/**
 * GET /orders/:orderId
 * Get order by ID
 * Matching: OrderApiService.getOrderById()
 */
exports.getOrderById = async (req, res) => {
  try {
    const { orderId } = req.params;
    const user = req.user;

    const query = { _id: orderId };
    // Users can only see their own orders, retailers/wholesalers can see their orders
    if (user.role === 'customer') {
      query.userId = user._id;
    } else if (user.role === 'retailer') {
      query.retailerId = user._id;
    } else if (user.role === 'wholesaler') {
      query.wholesalerId = user._id;
    }

    const order = await Order.findOne(query)
      .populate('items.productId', 'name images')
      .populate('userId', 'name email')
      .lean();

    if (!order) {
      return res.status(404).json(
        errorResponse(
          [createApiError('order', 'Order not found')],
          'Order not found'
        )
      );
    }

    const orderResponse = {
      id: order._id.toString(),
      userId: order.userId._id.toString(),
      userRole: user.role,
      items: order.items.map(item => ({
        productId: item.productId?._id.toString() || item.productId.toString(),
        quantity: item.quantity,
        price: item.price,
        productName: item.productName,
        totalPrice: item.price * item.quantity,
      })),
      totalAmount: order.totalAmount,
      finalAmount: order.finalAmount,
      paymentMethod: order.paymentMethod,
      paymentStatus: order.paymentStatus,
      deliveryAddress: order.deliveryAddress,
      status: order.status,
      trackingNumber: order.trackingNumber,
      createdAt: order.createdAt.toISOString(),
    };

    res.json(successResponse(orderResponse));
  } catch (error) {
    console.error('Get order error:', error);
    res.status(500).json(errorResponse(createApiError('order', error.message), 'Failed to get order'));
  }
};

/**
 * GET /retailers/orders/customers
 * Get retailer orders (from customers)
 * Matching: OrderApiService.getRetailerCustomerOrders()
 */
exports.getRetailerCustomerOrders = async (req, res) => {
  try {
    const user = req.user;
    if (user.role !== 'retailer') {
      return res.status(403).json(
        errorResponse(
          [createApiError('order', 'Access denied')],
          'Only retailers can access this endpoint'
        )
      );
    }

    const pagination = parsePagination(req.query);
    const { status } = req.query;

    const query = { retailerId: user._id };
    if (status) query.status = status;

    const [orders, totalItems] = await Promise.all([
      Order.find(query)
        .populate('userId', 'name email')
        .sort({ placedAt: -1 })
        .skip(pagination.skip)
        .limit(pagination.limit)
        .lean(),
      Order.countDocuments(query),
    ]);

    const ordersResponse = orders.map(order => ({
      id: order._id.toString(),
      userId: order.userId._id.toString(),
      userRole: 'customer',
      items: order.items,
      totalAmount: order.totalAmount,
      finalAmount: order.finalAmount,
      status: order.status,
      createdAt: order.createdAt.toISOString(),
    }));

    const paginationMeta = calculatePagination(totalItems, pagination.page, pagination.pageSize);

    res.json(successResponse({
      data: ordersResponse,
      ...paginationMeta,
    }));
  } catch (error) {
    console.error('Get retailer orders error:', error);
    res.status(500).json(errorResponse(createApiError('order', error.message), 'Failed to get retailer orders'));
  }
};

/**
 * GET /retailers/orders/wholesalers
 * Get retailer orders (from wholesalers)
 * Matching: OrderApiService.getRetailerWholesalerOrders()
 */
exports.getRetailerWholesalerOrders = async (req, res) => {
  try {
    const user = req.user;
    if (user.role !== 'retailer') {
      return res.status(403).json(
        errorResponse(
          [createApiError('order', 'Access denied')],
          'Only retailers can access this endpoint'
        )
      );
    }

    const pagination = parsePagination(req.query);
    const { status } = req.query;

    // Orders where retailer is the customer ordering from wholesaler
    const query = { userId: user._id, wholesalerId: { $exists: true } };
    if (status) query.status = status;

    const [orders, totalItems] = await Promise.all([
      Order.find(query)
        .populate('wholesalerId', 'name businessName')
        .sort({ placedAt: -1 })
        .skip(pagination.skip)
        .limit(pagination.limit)
        .lean(),
      Order.countDocuments(query),
    ]);

    const ordersResponse = orders.map(order => ({
      id: order._id.toString(),
      userId: order.userId.toString(),
      userRole: 'retailer',
      items: order.items,
      totalAmount: order.totalAmount,
      finalAmount: order.finalAmount,
      status: order.status,
      createdAt: order.createdAt.toISOString(),
    }));

    const paginationMeta = calculatePagination(totalItems, pagination.page, pagination.pageSize);

    res.json(successResponse({
      data: ordersResponse,
      ...paginationMeta,
    }));
  } catch (error) {
    console.error('Get retailer wholesaler orders error:', error);
    res.status(500).json(errorResponse(createApiError('order', error.message), 'Failed to get retailer orders'));
  }
};

/**
 * GET /wholesalers/orders/retailers
 * Get wholesaler orders (from retailers)
 * Matching: OrderApiService.getWholesalerRetailerOrders()
 */
exports.getWholesalerRetailerOrders = async (req, res) => {
  try {
    const user = req.user;
    if (user.role !== 'wholesaler') {
      return res.status(403).json(
        errorResponse(
          [createApiError('order', 'Access denied')],
          'Only wholesalers can access this endpoint'
        )
      );
    }

    const pagination = parsePagination(req.query);
    const { status } = req.query;

    const query = { wholesalerId: user._id };
    if (status) query.status = status;

    const [orders, totalItems] = await Promise.all([
      Order.find(query)
        .populate('userId', 'name email businessName')
        .sort({ placedAt: -1 })
        .skip(pagination.skip)
        .limit(pagination.limit)
        .lean(),
      Order.countDocuments(query),
    ]);

    const ordersResponse = orders.map(order => ({
      id: order._id.toString(),
      userId: order.userId._id.toString(),
      userRole: 'retailer',
      items: order.items,
      totalAmount: order.totalAmount,
      finalAmount: order.finalAmount,
      status: order.status,
      createdAt: order.createdAt.toISOString(),
    }));

    const paginationMeta = calculatePagination(totalItems, pagination.page, pagination.pageSize);

    res.json(successResponse({
      data: ordersResponse,
      ...paginationMeta,
    }));
  } catch (error) {
    console.error('Get wholesaler orders error:', error);
    res.status(500).json(errorResponse(createApiError('order', error.message), 'Failed to get wholesaler orders'));
  }
};

/**
 * PATCH /orders/:orderId
 * Update order status
 * Matching: OrderApiService.updateOrderStatus()
 */
exports.updateOrderStatus = async (req, res) => {
  try {
    const user = req.user;
    const { orderId } = req.params;
    const { status, trackingNumber } = req.body;

    if (!['retailer', 'wholesaler'].includes(user.role)) {
      return res.status(403).json(
        errorResponse(
          [createApiError('order', 'Only retailers and wholesalers can update order status')],
          'Access denied'
        )
      );
    }

    const query = { _id: orderId };
    if (user.role === 'retailer') {
      query.retailerId = user._id;
    } else if (user.role === 'wholesaler') {
      query.wholesalerId = user._id;
    }

    const order = await Order.findOne(query);
    if (!order) {
      return res.status(404).json(
        errorResponse(
          [createApiError('order', 'Order not found')],
          'Order not found'
        )
      );
    }

    // Update status
    if (status) {
      order.status = status;
      order.trackingInfo.push({
        status: status,
        message: `Order status updated to ${status}`,
        timestamp: new Date(),
      });
    }

    if (trackingNumber) {
      order.trackingNumber = trackingNumber;
    }

    await order.save();

    // Create notification for customer
    await Notification.create({
      userId: order.userId,
      type: 'order',
      title: 'Order Status Updated',
      message: `Your order #${order._id.toString().slice(-6)} status has been updated to ${status}`,
      data: { orderId: order._id.toString(), status },
    });

    const orderResponse = {
      id: order._id.toString(),
      status: order.status,
      trackingNumber: order.trackingNumber,
      updatedAt: order.updatedAt.toISOString(),
    };

    res.json(successResponse(orderResponse, 'Order status updated successfully'));
  } catch (error) {
    console.error('Update order status error:', error);
    res.status(500).json(errorResponse(createApiError('order', error.message), 'Failed to update order status'));
  }
};

/**
 * GET /orders/:orderId/tracking
 * Track order
 * Matching: OrderApiService.trackOrder()
 */
exports.trackOrder = async (req, res) => {
  try {
    const { orderId } = req.params;
    const user = req.user;

    const query = { _id: orderId };
    if (user.role === 'customer') {
      query.userId = user._id;
    } else if (user.role === 'retailer') {
      query.$or = [{ retailerId: user._id }, { userId: user._id }];
    } else if (user.role === 'wholesaler') {
      query.$or = [{ wholesalerId: user._id }, { userId: user._id }];
    }

    const order = await Order.findOne(query).lean();

    if (!order) {
      return res.status(404).json(
        errorResponse(
          [createApiError('order', 'Order not found')],
          'Order not found'
        )
      );
    }

    // Format tracking info (matching Dart OrderTracking structure)
    const trackingResponse = {
      orderId: order._id.toString(),
      status: order.status,
      updates: order.trackingInfo.map(update => ({
        status: update.status,
        message: update.message,
        timestamp: update.timestamp.toISOString(),
        location: update.location,
      })),
      estimatedDeliveryDate: order.scheduledDeliveryDate?.toISOString(),
      trackingNumber: order.trackingNumber,
    };

    res.json(successResponse(trackingResponse));
  } catch (error) {
    console.error('Track order error:', error);
    res.status(500).json(errorResponse(createApiError('order', error.message), 'Failed to track order'));
  }
};

/**
 * GET /orders/history
 * Get order history
 * Matching: OrderApiService.getOrderHistory()
 */
exports.getOrderHistory = async (req, res) => {
  try {
    const user = req.user;
    const pagination = parsePagination(req.query);
    const { startDate, endDate } = req.query;

    const query = { userId: user._id };
    
    if (startDate || endDate) {
      query.placedAt = {};
      if (startDate) query.placedAt.$gte = new Date(startDate);
      if (endDate) query.placedAt.$lte = new Date(endDate);
    }

    const [orders, totalItems] = await Promise.all([
      Order.find(query)
        .sort({ placedAt: -1 })
        .skip(pagination.skip)
        .limit(pagination.limit)
        .lean(),
      Order.countDocuments(query),
    ]);

    const ordersResponse = orders.map(order => ({
      id: order._id.toString(),
      userId: order.userId.toString(),
      userRole: 'customer',
      items: order.items,
      totalAmount: order.totalAmount,
      finalAmount: order.finalAmount,
      status: order.status,
      createdAt: order.createdAt.toISOString(),
    }));

    const paginationMeta = calculatePagination(totalItems, pagination.page, pagination.pageSize);

    res.json(successResponse({
      data: ordersResponse,
      ...paginationMeta,
    }));
  } catch (error) {
    console.error('Get order history error:', error);
    res.status(500).json(errorResponse(createApiError('order', error.message), 'Failed to get order history'));
  }
};
