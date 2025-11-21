const Product = require('../models/Product');
const Category = require('../models/Category');
const { successResponse } = require('../utils/response.util');
const { validateProductPayload, validateStockUpdatePayload, validateImportWholesalerPayload } = require('../utils/validation.util');
const { ValidationError, NotFoundError, ForbiddenError } = require('../utils/error.util');
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
      sourceType: product.sourceType,
      sourceProductId: product.sourceProductId?.toString(),
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
exports.addProduct = async (req, res, next) => {
  try {
    const user = req.user;
    if (!['retailer', 'wholesaler'].includes(user.role)) {
      throw new ForbiddenError('Only retailers and wholesalers can add products');
    }

    // Validate product payload
    validateProductPayload(req.body, false);

    const { name, description, price, stock, categoryId, images, weight, region, isLocal } = req.body;

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

    // Ensure stock is non-negative
    if (productData.stock < 0) {
      throw new ValidationError('Stock cannot be negative', 'stock');
    }

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
      sourceType: product.sourceType,
      sourceProductId: product.sourceProductId?.toString(),
      createdAt: product.createdAt.toISOString(),
    };

    res.json(successResponse(productResponse, 'Product added to inventory'));
  } catch (error) {
    next(error);
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
      sourceType: product.sourceType,
      sourceProductId: product.sourceProductId?.toString(),
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
exports.updateStock = async (req, res, next) => {
  try {
    const user = req.user;
    if (!['retailer', 'wholesaler'].includes(user.role)) {
      throw new ForbiddenError('Only retailers and wholesalers can update stock');
    }

    // Validate stock update payload
    validateStockUpdatePayload(req.body);

    const { productId } = req.params;
    const { quantity, operation } = req.body;

    const query = { _id: productId };
    if (user.role === 'retailer') {
      query.retailerId = user._id;
    } else if (user.role === 'wholesaler') {
      query.wholesalerId = user._id;
    }

    const product = await Product.findOne(query);
    if (!product) {
      throw new NotFoundError('Product not found');
    }

    // Update stock based on operation - ensure never negative
    const qty = parseInt(quantity);
    if (operation === 'add') {
      product.stock = Math.max(0, (product.stock || 0) + qty);
    } else if (operation === 'subtract') {
      product.stock = Math.max(0, (product.stock || 0) - qty);
    } else if (operation === 'set') {
      if (qty < 0) {
        throw new ValidationError('Stock cannot be negative', 'quantity');
      }
      product.stock = qty;
    }

    // Mark as inactive if stock is 0
    if (product.stock === 0) {
      product.isActive = false;
    } else {
      product.isActive = true;
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

/**
 * POST /inventory/import-from-wholesaler
 * Import product from wholesaler (Proxy Inventory)
 * Matching: InventoryApiService.importProductFromWholesaler()
 */
exports.importProductFromWholesaler = async (req, res, next) => {
  try {
    const user = req.user;
    if (user.role !== 'retailer') {
      throw new ForbiddenError('Only retailers can import products from wholesalers');
    }

    // Validate import payload
    validateImportWholesalerPayload(req.body);

    const { productId, stock, price } = req.body;

    // Find the wholesaler product
    const wholesalerProduct = await Product.findOne({ 
      _id: productId, 
      wholesalerId: { $exists: true },
      isActive: true 
    }).populate('categoryId', 'name slug');

    if (!wholesalerProduct) {
      throw new NotFoundError('Wholesaler product not found');
    }

    // Check if retailer already imported this product
    const existingProxyProduct = await Product.findOne({
      retailerId: user._id,
      sourceProductId: wholesalerProduct._id,
    });

    if (existingProxyProduct) {
      throw new ValidationError('You have already imported this product', 'productId');
    }

    // Create proxy product for retailer
    const proxyProductData = {
      name: wholesalerProduct.name,
      description: wholesalerProduct.description,
      price: price !== undefined ? parseFloat(price) : wholesalerProduct.price, // Retailer can override
      stock: stock !== undefined ? parseInt(stock) : 0, // Retailer can set initial stock
      categoryId: wholesalerProduct.categoryId._id,
      images: wholesalerProduct.images,
      weight: wholesalerProduct.weight,
      region: wholesalerProduct.region || user.location?.region,
      isLocal: wholesalerProduct.isLocal,
      isActive: true,
      retailerId: user._id,
      wholesalerId: wholesalerProduct.wholesalerId, // Keep reference to original wholesaler
      sourceType: 'wholesaler',
      sourceProductId: wholesalerProduct._id,
    };

    const proxyProduct = new Product(proxyProductData);
    await proxyProduct.save();

    // Update category product count
    await Category.findByIdAndUpdate(wholesalerProduct.categoryId._id, { $inc: { productCount: 1 } });

    await proxyProduct.populate('categoryId', 'name slug');

    const productResponse = {
      id: proxyProduct._id.toString(),
      name: proxyProduct.name,
      description: proxyProduct.description,
      price: proxyProduct.price,
      category: proxyProduct.categoryId?.name || '',
      categoryId: proxyProduct.categoryId?._id.toString(),
      imageUrl: proxyProduct.images?.[0] || null,
      images: proxyProduct.images || [],
      inStock: proxyProduct.stock > 0,
      stock: proxyProduct.stock,
      weight: proxyProduct.weight,
      region: proxyProduct.region,
      isLocal: proxyProduct.isLocal,
      sourceType: proxyProduct.sourceType,
      sourceProductId: proxyProduct.sourceProductId?.toString(),
      createdAt: proxyProduct.createdAt.toISOString(),
    };

    res.json(successResponse(productResponse, 'Product imported from wholesaler successfully'));
  } catch (error) {
    next(error);
  }
};