// Orders Controller

const Order = require('../models/Order');
const Product = require('../models/Product');
const User = require('../models/User');

// Create Order (Customer)
exports.createOrder = async (req, res, next) => {
  try {
    const userId = req.user.userId; // From auth middleware
    const {
      items,
      deliveryAddress,
      scheduledDeliveryDate,
      deliveryInstructions,
      paymentMethod,
      couponCode,
    } = req.body;

    // Validate items and calculate totals
    let totalAmount = 0;
    const orderItems = [];

    for (const item of items) {
      const product = await Product.findById(item.productId);
      if (!product || !product.isAvailable) {
        return res.status(400).json({
          success: false,
          message: `Product ${item.productId} not available`,
        });
      }

      if (product.stockQuantity < item.quantity) {
        return res.status(400).json({
          success: false,
          message: `Insufficient stock for ${product.name}`,
        });
      }

      const itemTotal = product.price * item.quantity;
      totalAmount += itemTotal;

      orderItems.push({
        productId: product._id,
        productName: product.name,
        productImage: product.cover,
        quantity: item.quantity,
        unitPrice: product.price,
        totalPrice: itemTotal,
        weight: product.weight,
      });

      // Update stock (reserve or deduct based on your logic)
      product.stockQuantity -= item.quantity;
      if (product.stockQuantity <= 0) {
        product.isAvailable = false;
      }
      await product.save();
    }

    // Apply coupon discount if provided
    let discountAmount = 0;
    // Coupon validation logic here

    const finalAmount = totalAmount - discountAmount;

    // Get retailer info from first product
    const firstProduct = await Product.findById(items[0].productId);
    const retailerId = firstProduct.retailerId;
    const retailer = await User.findById(retailerId);

    // Create order
    const order = new Order({
      userId,
      userRole: 'customer',
      items: orderItems,
      totalAmount,
      discountAmount: discountAmount > 0 ? discountAmount : undefined,
      finalAmount,
      deliveryAddress,
      scheduledDeliveryDate: scheduledDeliveryDate
        ? new Date(scheduledDeliveryDate)
        : undefined,
      deliveryInstructions,
      paymentMethod,
      paymentStatus: paymentMethod === 'online' ? 'pending' : 'pending',
      status: 'confirmed',
      retailerId,
      retailerName: retailer?.businessName || retailer?.name,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    await order.save();

    // Format response to match Flutter OrderModel
    res.status(201).json({
      success: true,
      message: 'Order created successfully',
      data: formatOrder(order),
    });
  } catch (error) {
    next(error);
  }
};

// Get Customer Orders
exports.getCustomerOrders = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { page = 1, pageSize = 20, status } = req.query;

    const query = { userId, userRole: 'customer' };
    if (status) query.status = status;

    const skip = (parseInt(page) - 1) * parseInt(pageSize);
    const limit = parseInt(pageSize);

    const [orders, totalItems] = await Promise.all([
      Order.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate('retailerId', 'name businessName'),
      Order.countDocuments(query),
    ]);

    const totalPages = Math.ceil(totalItems / limit);

    res.json({
      success: true,
      data: {
        data: orders.map((o) => formatOrder(o)),
        currentPage: parseInt(page),
        totalPages,
        totalItems,
        pageSize: limit,
        hasNext: parseInt(page) < totalPages,
        hasPrevious: parseInt(page) > 1,
      },
    });
  } catch (error) {
    next(error);
  }
};

// Get Order by ID
exports.getOrderById = async (req, res, next) => {
  try {
    const { orderId } = req.params;
    const userId = req.user.userId;

    const order = await Order.findOne({
      _id: orderId,
      $or: [
        { userId },
        { retailerId: userId },
        { wholesalerId: userId },
      ],
    })
      .populate('retailerId', 'name businessName')
      .populate('wholesalerId', 'name businessName');

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found',
      });
    }

    res.json({
      success: true,
      data: formatOrder(order),
    });
  } catch (error) {
    next(error);
  }
};

// Update Order Status
exports.updateOrderStatus = async (req, res, next) => {
  try {
    const { orderId } = req.params;
    const { status, trackingNumber, notes } = req.body;
    const userId = req.user.userId;

    // Validate status
    const validStatuses = ['confirmed', 'processing', 'shipped', 'delivery', 'cancelled'];
    if (!status || !validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: `Invalid status. Must be one of: ${validStatuses.join(', ')}`,
      });
    }

    const order = await Order.findOne({
      _id: orderId,
      $or: [
        { retailerId: userId },
        { wholesalerId: userId },
      ],
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found or unauthorized',
      });
    }

    // Log status change
    const oldStatus = order.status;
    if (oldStatus !== status) {
      order.statusLogs = order.statusLogs || [];
      order.statusLogs.push({
        oldStatus,
        newStatus: status,
        changedBy: userId,
        timestamp: new Date(),
        notes: notes || `Status changed from ${oldStatus} to ${status}`,
      });
    }

    order.status = status;
    if (trackingNumber) order.trackingNumber = trackingNumber;
    order.updatedAt = new Date();

    if (status === 'delivery') {
      order.deliveredAt = new Date();
    }

    await order.save();

    res.json({
      success: true,
      message: 'Order status updated',
      data: formatOrder(order),
    });
  } catch (error) {
    next(error);
  }
};

// Track Order
exports.trackOrder = async (req, res, next) => {
  try {
    const { orderId } = req.params;
    const userId = req.user.userId;

    const order = await Order.findOne({
      _id: orderId,
      userId,
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found',
      });
    }

    // Build tracking updates
    const updates = [
      {
        status: 'confirmed',
        message: 'Order confirmed',
        timestamp: order.createdAt,
      },
      // Add more tracking updates based on order status
    ];

    res.json({
      success: true,
      data: {
        orderId: order._id.toString(),
        status: order.status,
        updates,
        estimatedDeliveryDate: order.scheduledDeliveryDate?.toISOString(),
        trackingNumber: order.trackingNumber,
      },
    });
  } catch (error) {
    next(error);
  }
};

// Get Order History
exports.getOrderHistory = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { page = 1, pageSize = 20, startDate, endDate } = req.query;

    const query = { userId };

    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = new Date(startDate);
      if (endDate) query.createdAt.$lte = new Date(endDate);
    }

    const skip = (parseInt(page) - 1) * parseInt(pageSize);
    const limit = parseInt(pageSize);

    const [orders, totalItems] = await Promise.all([
      Order.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit),
      Order.countDocuments(query),
    ]);

    const totalPages = Math.ceil(totalItems / limit);

    res.json({
      success: true,
      data: {
        data: orders.map((o) => formatOrder(o)),
        currentPage: parseInt(page),
        totalPages,
        totalItems,
        pageSize: limit,
        hasNext: parseInt(page) < totalPages,
        hasPrevious: parseInt(page) > 1,
      },
    });
  } catch (error) {
    next(error);
  }
};

// Get User Orders (by userId param)
exports.getUserOrders = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const { page = 1, pageSize = 20, status } = req.query;
    const requestingUserId = req.user.userId;

    // Authorization: Only allow users to view their own orders or admin/retailer
    if (userId !== requestingUserId && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized to view these orders',
      });
    }

    const query = { userId };
    if (status) query.status = status;

    const skip = (parseInt(page) - 1) * parseInt(pageSize);
    const limit = parseInt(pageSize);

    const [orders, totalItems] = await Promise.all([
      Order.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate('retailerId', 'name businessName'),
      Order.countDocuments(query),
    ]);

    const totalPages = Math.ceil(totalItems / limit);

    res.json({
      success: true,
      data: {
        data: orders.map((o) => formatOrder(o)),
        currentPage: parseInt(page),
        totalPages,
        totalItems,
        pageSize: limit,
        hasNext: parseInt(page) < totalPages,
        hasPrevious: parseInt(page) > 1,
      },
    });
  } catch (error) {
    next(error);
  }
};

// Helper function to format order response
function formatOrder(order) {
  return {
    id: order._id.toString(),
    userId: order.userId.toString(),
    userRole: order.userRole,
    items: order.items,
    totalAmount: order.totalAmount,
    discountAmount: order.discountAmount,
    finalAmount: order.finalAmount,
    deliveryAddress: order.deliveryAddress,
    scheduledDeliveryDate: order.scheduledDeliveryDate?.toISOString(),
    deliveryInstructions: order.deliveryInstructions,
    paymentMethod: order.paymentMethod,
    paymentStatus: order.paymentStatus,
    transactionId: order.transactionId,
    status: order.status,
    statusLogs: order.statusLogs,
    createdAt: order.createdAt.toISOString(),
    updatedAt: order.updatedAt.toISOString(),
    deliveredAt: order.deliveredAt?.toISOString(),
    retailerId: order.retailerId?.toString(),
    retailerName: order.retailerName,
    wholesalerId: order.wholesalerId?.toString(),
    wholesalerName: order.wholesalerName,
    hasFeedback: order.hasFeedback || false,
    rating: order.rating,
    feedbackComment: order.feedbackComment,
  };
}

