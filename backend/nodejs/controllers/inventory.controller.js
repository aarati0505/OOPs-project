const Product = require('../models/Product');
const Category = require('../models/Category');
const { successResponse, errorResponse, createApiError } = require('../utils/response.util');
const { parsePagination, calculatePagination } = require('../utils/pagination.util');

/**
 * Inventory Controller
 * Matching Dart InventoryApiService methods
 * Only accessible to retailer/wholesaler roles
 */

/**
 * GET /inventory
 * Get retailer/wholesaler inventory
 * Matching: InventoryApiService.getInventory()
 */
exports.getInventory = async (req, res) => {
  try {
    const user = req.user;
    if (!['retailer', 'wholesaler'].includes(user.role)) {
      return res.status(403).json(
        errorResponse(
          [createApiError('inventory', 'Access denied')],
          'Only retailers and wholesalers can access inventory'
        )
      );
    }

    const pagination = parsePagination(req.query);
    const { category, inStock } = req.query;

    const query = {};
    
    // Filter by user role
    if (user.role === 'retailer') {
      query.retailerId = user._id;
    } else if (user.role === 'wholesaler') {
      query.wholesalerId = user._id;
    }

    // Category filter
    if (category) {
      const categoryDoc = await Category.findOne({ slug: category.toLowerCase() });
      if (categoryDoc) {
        query.categoryId = categoryDoc._id;
      }
    }

    // Stock filter
    if (inStock === 'true') {
      query.stock = { $gt: 0 };
    } else if (inStock === 'false') {
      query.stock = { $lte: 0 };
    }

    const [products, totalItems] = await Promise.all([
      Product.find(query)
        .populate('categoryId', 'name slug')
        .sort({ createdAt: -1 })
        .skip(pagination.skip)
        .limit(pagination.limit)
        .lean(),
      Product.countDocuments(query),
    ]);

    const productsResponse = products.map(product => ({
      id: product._id.toString(),
      name: product.name,
      description: product.description,
      price: product.price,
      category: product.categoryId?.name || '',
      categoryId: product.categoryId?._id.toString(),
      imageUrl: product.images?.[0] || null,
      images: product.images || [],
      inStock: product.stock > 0,
      stock: product.stock,
      weight: product.weight,
      region: product.region,
      isLocal: product.isLocal,
      isActive: product.isActive,
      createdAt: product.createdAt.toISOString(),
    }));

    const paginationMeta = calculatePagination(totalItems, pagination.page, pagination.pageSize);

    res.json(successResponse({
      data: productsResponse,
      ...paginationMeta,
    }));
  } catch (error) {
    console.error('Get inventory error:', error);
    res.status(500).json(errorResponse(createApiError('inventory', error.message), 'Failed to get inventory'));
  }
};

/**
 * POST /inventory/products
 * Add product to inventory
 * Matching: InventoryApiService.addProduct()
 */
exports.addProduct = async (req, res) => {
  try {
    const user = req.user;
    if (!['retailer', 'wholesaler'].includes(user.role)) {
      return res.status(403).json(
        errorResponse(
          [createApiError('inventory', 'Access denied')],
          'Only retailers and wholesalers can add products'
        )
      );
    }

    const { name, description, price, stock, categoryId, images, weight, region, isLocal } = req.body;

    if (!name || !price || stock === undefined || !categoryId) {
      return res.status(400).json(
        errorResponse(
          [createApiError('inventory', 'Name, price, stock, and categoryId are required')],
          'Validation error'
        )
      );
    }

    const productData = {
      name,
      description,
      price: parseFloat(price),
      stock: parseInt(stock),
      categoryId,
      images: images || [],
      weight,
      region: region || user.location?.region,
      isLocal: isLocal !== undefined ? isLocal : true,
      isActive: true,
    };

    // Set retailerId or wholesalerId based on role
    if (user.role === 'retailer') {
      productData.retailerId = user._id;
    } else if (user.role === 'wholesaler') {
      productData.wholesalerId = user._id;
    }

    const product = new Product(productData);
    await product.save();

    // Update category product count
    await Category.findByIdAndUpdate(categoryId, { $inc: { productCount: 1 } });

    await product.populate('categoryId', 'name slug');

    const productResponse = {
      id: product._id.toString(),
      name: product.name,
      description: product.description,
      price: product.price,
      category: product.categoryId?.name || '',
      categoryId: product.categoryId?._id.toString(),
      imageUrl: product.images?.[0] || null,
      images: product.images || [],
      inStock: product.stock > 0,
      stock: product.stock,
      weight: product.weight,
      region: product.region,
      isLocal: product.isLocal,
      createdAt: product.createdAt.toISOString(),
    };

    res.json(successResponse(productResponse, 'Product added to inventory'));
  } catch (error) {
    console.error('Add product error:', error);
    res.status(500).json(errorResponse(createApiError('inventory', error.message), 'Failed to add product'));
  }
};

/**
 * PUT /inventory/products/:productId
 * Update product in inventory
 * Matching: InventoryApiService.updateProduct()
 */
exports.updateProduct = async (req, res) => {
  try {
    const user = req.user;
    const { productId } = req.params;
    const updates = req.body;

    if (!['retailer', 'wholesaler'].includes(user.role)) {
      return res.status(403).json(
        errorResponse(
          [createApiError('inventory', 'Access denied')],
          'Only retailers and wholesalers can update products'
        )
      );
    }

    // Find product and verify ownership
    const query = { _id: productId };
    if (user.role === 'retailer') {
      query.retailerId = user._id;
    } else if (user.role === 'wholesaler') {
      query.wholesalerId = user._id;
    }

    const product = await Product.findOne(query);
    if (!product) {
      return res.status(404).json(
        errorResponse(
          [createApiError('inventory', 'Product not found')],
          'Product not found'
        )
      );
    }

    // Update allowed fields
    const allowedUpdates = ['name', 'description', 'price', 'images', 'weight', 'region', 'isLocal', 'isActive'];
    allowedUpdates.forEach(field => {
      if (updates[field] !== undefined) {
        product[field] = updates[field];
      }
    });

    await product.save();
    await product.populate('categoryId', 'name slug');

    const productResponse = {
      id: product._id.toString(),
      name: product.name,
      description: product.description,
      price: product.price,
      category: product.categoryId?.name || '',
      imageUrl: product.images?.[0] || null,
      images: product.images || [],
      inStock: product.stock > 0,
      stock: product.stock,
      weight: product.weight,
      region: product.region,
      isLocal: product.isLocal,
      updatedAt: product.updatedAt.toISOString(),
    };

    res.json(successResponse(productResponse, 'Product updated'));
  } catch (error) {
    console.error('Update product error:', error);
    res.status(500).json(errorResponse(createApiError('inventory', error.message), 'Failed to update product'));
  }
};

/**
 * DELETE /inventory/products/:productId
 * Delete product from inventory
 * Matching: InventoryApiService.deleteProduct()
 */
exports.deleteProduct = async (req, res) => {
  try {
    const user = req.user;
    const { productId } = req.params;

    if (!['retailer', 'wholesaler'].includes(user.role)) {
      return res.status(403).json(
        errorResponse(
          [createApiError('inventory', 'Access denied')],
          'Only retailers and wholesalers can delete products'
        )
      );
    }

    const query = { _id: productId };
    if (user.role === 'retailer') {
      query.retailerId = user._id;
    } else if (user.role === 'wholesaler') {
      query.wholesalerId = user._id;
    }

    const product = await Product.findOne(query);
    if (!product) {
      return res.status(404).json(
        errorResponse(
          [createApiError('inventory', 'Product not found')],
          'Product not found'
        )
      );
    }

    // Soft delete (set isActive to false) or hard delete
    await Product.findByIdAndDelete(productId);

    // Update category product count
    await Category.findByIdAndUpdate(product.categoryId, { $inc: { productCount: -1 } });

    res.json(successResponse(null, 'Product deleted'));
  } catch (error) {
    console.error('Delete product error:', error);
    res.status(500).json(errorResponse(createApiError('inventory', error.message), 'Failed to delete product'));
  }
};

/**
 * PATCH /inventory/stock/:productId
 * Update stock quantity
 * Matching: InventoryApiService.updateStock()
 */
exports.updateStock = async (req, res) => {
  try {
    const user = req.user;
    const { productId } = req.params;
    const { quantity, operation } = req.body;

    if (!['retailer', 'wholesaler'].includes(user.role)) {
      return res.status(403).json(
        errorResponse(
          [createApiError('inventory', 'Access denied')],
          'Only retailers and wholesalers can update stock'
        )
      );
    }

    if (!quantity || !operation || !['add', 'subtract', 'set'].includes(operation)) {
      return res.status(400).json(
        errorResponse(
          [createApiError('inventory', 'Quantity and operation (add/subtract/set) are required')],
          'Validation error'
        )
      );
    }

    const query = { _id: productId };
    if (user.role === 'retailer') {
      query.retailerId = user._id;
    } else if (user.role === 'wholesaler') {
      query.wholesalerId = user._id;
    }

    const product = await Product.findOne(query);
    if (!product) {
      return res.status(404).json(
        errorResponse(
          [createApiError('inventory', 'Product not found')],
          'Product not found'
        )
      );
    }

    // Update stock based on operation
    const qty = parseInt(quantity);
    if (operation === 'add') {
      product.stock += qty;
    } else if (operation === 'subtract') {
      product.stock = Math.max(0, product.stock - qty);
    } else if (operation === 'set') {
      product.stock = qty;
    }

    await product.save();
    await product.populate('categoryId', 'name slug');

    const productResponse = {
      id: product._id.toString(),
      name: product.name,
      price: product.price,
      stock: product.stock,
      inStock: product.stock > 0,
      updatedAt: product.updatedAt.toISOString(),
    };

    res.json(successResponse(productResponse, 'Stock updated'));
  } catch (error) {
    console.error('Update stock error:', error);
    res.status(500).json(errorResponse(createApiError('inventory', error.message), 'Failed to update stock'));
  }
};

/**
 * GET /inventory/stats
 * Get inventory statistics
 * Matching: InventoryApiService.getInventoryStats()
 */
exports.getInventoryStats = async (req, res) => {
  try {
    const user = req.user;
    if (!['retailer', 'wholesaler'].includes(user.role)) {
      return res.status(403).json(
        errorResponse(
          [createApiError('inventory', 'Access denied')],
          'Only retailers and wholesalers can access inventory stats'
        )
      );
    }

    const query = {};
    if (user.role === 'retailer') {
      query.retailerId = user._id;
    } else if (user.role === 'wholesaler') {
      query.wholesalerId = user._id;
    }

    const [totalProducts, inStock, outOfStock, lowStock, totalValue] = await Promise.all([
      Product.countDocuments(query),
      Product.countDocuments({ ...query, stock: { $gt: 0 } }),
      Product.countDocuments({ ...query, stock: { $lte: 0 } }),
      Product.countDocuments({ ...query, stock: { $gt: 0, $lte: 10 } }), // Low stock threshold
      Product.aggregate([
        { $match: query },
        { $group: { _id: null, total: { $sum: { $multiply: ['$price', '$stock'] } } } },
      ]),
    ]);

    const stats = {
      totalProducts,
      inStock,
      outOfStock,
      lowStock,
      totalValue: totalValue[0]?.total || 0,
    };

    res.json(successResponse(stats));
  } catch (error) {
    console.error('Get inventory stats error:', error);
    res.status(500).json(errorResponse(createApiError('inventory', error.message), 'Failed to get inventory stats'));
  }
};
