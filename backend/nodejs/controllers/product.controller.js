const Product = require('../models/Product');
const Category = require('../models/Category');
const { successResponse, errorResponse, createApiError } = require('../utils/response.util');
const { parsePagination, calculatePagination } = require('../utils/pagination.util');

/**
 * Product Controller
 * Matching Dart ProductApiService methods
 */

/**
 * GET /products
 * Get all products with pagination and filters
 * Matching: ProductApiService.getProducts()
 */
exports.getProducts = async (req, res) => {
  try {
    const pagination = parsePagination(req.query);
    const { category, minPrice, maxPrice, search, inStock, region, latitude, longitude, maxDistance, sortBy, sortOrder } = req.query;
    const user = req.user;

    // Build query
    const query = { isActive: true };

    // Category filter
    if (category) {
      const categoryDoc = await Category.findOne({ slug: category.toLowerCase() });
      if (categoryDoc) {
        query.categoryId = categoryDoc._id;
      } else {
        // Return empty if category not found
        return res.json(successResponse({
          data: [],
          ...calculatePagination(0, pagination.page, pagination.pageSize),
        }));
      }
    }

    // Price range filter
    if (minPrice) query.price = { $gte: parseFloat(minPrice) };
    if (maxPrice) {
      query.price = query.price || {};
      query.price.$lte = parseFloat(maxPrice);
    }

    // Stock filter
    if (inStock === 'true') {
      query.stock = { $gt: 0 };
    } else if (inStock === 'false') {
      query.stock = { $lte: 0 };
    }

    // Region filter (for local products)
    if (region) {
      query.region = region;
    } else if (user?.location?.region) {
      // If user has region, show local products by default
      query.$or = [
        { region: user.location.region },
        { isLocal: false }, // Also show non-local products
      ];
    }

    // Search query
    if (search) {
      query.$text = { $search: search };
    }

    // Build sort
    let sort = {};
    if (sortBy) {
      sort[sortBy] = sortOrder === 'desc' ? -1 : 1;
    } else {
      sort.createdAt = -1; // Default: newest first
    }

    // Execute query with pagination
    const [products, totalItems] = await Promise.all([
      Product.find(query)
        .populate('categoryId', 'name slug')
        .populate('retailerId', 'name businessName')
        .populate('wholesalerId', 'name businessName')
        .sort(sort)
        .skip(pagination.skip)
        .limit(pagination.limit)
        .lean(),
      Product.countDocuments(query),
    ]);

    // Format products (matching Dart ProductModel structure)
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
      retailerId: product.retailerId?._id.toString(),
      wholesalerId: product.wholesalerId?._id.toString(),
      sourceType: product.sourceType,
      sourceProductId: product.sourceProductId?.toString(),
      rating: product.rating || 0,
      reviewCount: product.reviewCount || 0,
      createdAt: product.createdAt.toISOString(),
    }));

    const paginationMeta = calculatePagination(totalItems, pagination.page, pagination.pageSize);

    res.json(successResponse({
      data: productsResponse,
      ...paginationMeta,
    }));
  } catch (error) {
    console.error('Get products error:', error);
    res.status(500).json(errorResponse(createApiError('product', error.message), 'Failed to get products'));
  }
};

/**
 * GET /products/:productId
 * Get product by ID
 * Matching: ProductApiService.getProductById()
 */
exports.getProductById = async (req, res) => {
  try {
    const { productId } = req.params;

    const product = await Product.findById(productId)
      .populate('categoryId', 'name slug')
      .populate('retailerId', 'name businessName')
      .populate('wholesalerId', 'name businessName')
      .lean();

    if (!product || !product.isActive) {
      return res.status(404).json(
        errorResponse(
          [createApiError('product', 'Product not found')],
          'Product not found'
        )
      );
    }

    // Increment views
    await Product.findByIdAndUpdate(productId, { $inc: { views: 1 } });

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
      retailerId: product.retailerId?._id.toString(),
      wholesalerId: product.wholesalerId?._id.toString(),
      sourceType: product.sourceType,
      sourceProductId: product.sourceProductId?.toString(),
      rating: product.rating || 0,
      reviewCount: product.reviewCount || 0,
      createdAt: product.createdAt.toISOString(),
    };

    res.json(successResponse(productResponse));
  } catch (error) {
    console.error('Get product error:', error);
    res.status(500).json(errorResponse(createApiError('product', error.message), 'Failed to get product'));
  }
};

/**
 * GET /products/search
 * Search products
 * Matching: ProductApiService.searchProducts()
 */
exports.searchProducts = async (req, res) => {
  try {
    const { q, category, minPrice, maxPrice, latitude, longitude, maxDistance } = req.query;
    const pagination = parsePagination(req.query);
    const user = req.user;

    const query = { isActive: true };

    // Search query
    if (q) {
      query.$text = { $search: q };
    }

    // Category filter
    if (category) {
      const categoryDoc = await Category.findOne({ slug: category.toLowerCase() });
      if (categoryDoc) {
        query.categoryId = categoryDoc._id;
      }
    }

    // Price range
    if (minPrice) query.price = { $gte: parseFloat(minPrice) };
    if (maxPrice) {
      query.price = query.price || {};
      query.price.$lte = parseFloat(maxPrice);
    }

    // TODO: Implement distance-based filtering using latitude/longitude
    // For now, use region-based filtering
    if (user?.location?.region) {
      query.$or = [
        { region: user.location.region },
        { isLocal: false },
      ];
    }

    const [products, totalItems] = await Promise.all([
      Product.find(query)
        .populate('categoryId', 'name slug')
        .sort({ score: { $meta: 'textScore' } })
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
      imageUrl: product.images?.[0] || null,
      inStock: product.stock > 0,
      stock: product.stock,
      region: product.region,
      createdAt: product.createdAt.toISOString(),
    }));

    const paginationMeta = calculatePagination(totalItems, pagination.page, pagination.pageSize);

    res.json(successResponse({
      data: productsResponse,
      ...paginationMeta,
    }));
  } catch (error) {
    console.error('Search products error:', error);
    res.status(500).json(errorResponse(createApiError('product', error.message), 'Failed to search products'));
  }
};

/**
 * GET /products/category/:categoryId
 * Get products by category
 * Matching: ProductApiService.getProductsByCategory()
 */
exports.getProductsByCategory = async (req, res) => {
  try {
    const { categoryId } = req.params;
    const pagination = parsePagination(req.query);

    const category = await Category.findById(categoryId);
    if (!category) {
      return res.status(404).json(
        errorResponse(
          [createApiError('category', 'Category not found')],
          'Category not found'
        )
      );
    }

    const query = { categoryId: category._id, isActive: true };

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
      category: category.name,
      imageUrl: product.images?.[0] || null,
      inStock: product.stock > 0,
      stock: product.stock,
      createdAt: product.createdAt.toISOString(),
    }));

    const paginationMeta = calculatePagination(totalItems, pagination.page, pagination.pageSize);

    res.json(successResponse({
      data: productsResponse,
      ...paginationMeta,
    }));
  } catch (error) {
    console.error('Get products by category error:', error);
    res.status(500).json(errorResponse(createApiError('product', error.message), 'Failed to get products by category'));
  }
};

/**
 * GET /products/popular
 * Get popular products
 * Matching: ProductApiService.getPopularProducts()
 */
exports.getPopularProducts = async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;

    const products = await Product.find({ isActive: true })
      .populate('categoryId', 'name slug')
      .sort({ rating: -1, reviewCount: -1, views: -1 })
      .limit(limit)
      .lean();

    const productsResponse = products.map(product => ({
      id: product._id.toString(),
      name: product.name,
      description: product.description,
      price: product.price,
      category: product.categoryId?.name || '',
      imageUrl: product.images?.[0] || null,
      inStock: product.stock > 0,
      stock: product.stock,
      rating: product.rating || 0,
      reviewCount: product.reviewCount || 0,
      createdAt: product.createdAt.toISOString(),
    }));

    res.json(successResponse(productsResponse));
  } catch (error) {
    console.error('Get popular products error:', error);
    res.status(500).json(errorResponse(createApiError('product', error.message), 'Failed to get popular products'));
  }
};

/**
 * GET /products/new
 * Get new products
 * Matching: ProductApiService.getNewProducts()
 */
exports.getNewProducts = async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;

    const products = await Product.find({ isActive: true })
      .populate('categoryId', 'name slug')
      .sort({ createdAt: -1 })
      .limit(limit)
      .lean();

    const productsResponse = products.map(product => ({
      id: product._id.toString(),
      name: product.name,
      description: product.description,
      price: product.price,
      category: product.categoryId?.name || '',
      imageUrl: product.images?.[0] || null,
      inStock: product.stock > 0,
      stock: product.stock,
      createdAt: product.createdAt.toISOString(),
    }));

    res.json(successResponse(productsResponse));
  } catch (error) {
    console.error('Get new products error:', error);
    res.status(500).json(errorResponse(createApiError('product', error.message), 'Failed to get new products'));
  }
};

/**
 * GET /products/region
 * Get region-specific products
 * Matching: ProductApiService.getRegionSpecificProducts()
 */
exports.getRegionSpecificProducts = async (req, res) => {
  try {
    const { region } = req.query;
    const pagination = parsePagination(req.query);

    if (!region) {
      return res.status(400).json(
        errorResponse(
          [createApiError('product', 'Region is required')],
          'Validation error'
        )
      );
    }

    const query = { region: region, isActive: true, isLocal: true };

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
      imageUrl: product.images?.[0] || null,
      inStock: product.stock > 0,
      stock: product.stock,
      region: product.region,
      createdAt: product.createdAt.toISOString(),
    }));

    const paginationMeta = calculatePagination(totalItems, pagination.page, pagination.pageSize);

    res.json(successResponse({
      data: productsResponse,
      ...paginationMeta,
    }));
  } catch (error) {
    console.error('Get region-specific products error:', error);
    res.status(500).json(errorResponse(createApiError('product', error.message), 'Failed to get region-specific products'));
  }
};


/**
 * POST /products
 * Create new product (retailers/wholesalers only)
 */
exports.createProduct = async (req, res) => {
  try {
    const user = req.user;
    
    // Check if user is retailer or wholesaler
    if (user.role !== 'retailer' && user.role !== 'wholesaler') {
      return res.status(403).json(
        errorResponse(
          [createApiError('auth', 'Only retailers and wholesalers can create products')],
          'Forbidden'
        )
      );
    }

    const { name, description, price, stock, categoryId, images, weight, region, isLocal } = req.body;

    // Validation
    if (!name || !price || stock === undefined || !categoryId) {
      return res.status(400).json(
        errorResponse(
          [createApiError('product', 'Name, price, stock, and category are required')],
          'Validation error'
        )
      );
    }

    // Verify category exists
    const category = await Category.findById(categoryId);
    if (!category) {
      return res.status(404).json(
        errorResponse(
          [createApiError('category', 'Category not found')],
          'Category not found'
        )
      );
    }

    // Create product
    const productData = {
      name,
      description,
      price: parseFloat(price),
      stock: parseInt(stock),
      categoryId,
      images: images || [],
      weight,
      region: region || user.location?.region,
      isLocal: isLocal !== undefined ? isLocal : false,
      isActive: true,
    };

    // Set retailer or wholesaler ID
    if (user.role === 'retailer') {
      productData.retailerId = user.id;
      productData.sourceType = 'retailer';
    } else if (user.role === 'wholesaler') {
      productData.wholesalerId = user.id;
      productData.sourceType = 'wholesaler';
    }

    const product = await Product.create(productData);

    // Populate category for response
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
      retailerId: product.retailerId?.toString(),
      wholesalerId: product.wholesalerId?.toString(),
      sourceType: product.sourceType,
      rating: 0,
      reviewCount: 0,
      createdAt: product.createdAt.toISOString(),
    };

    console.log(`✅ Product created: ${product.name} by ${user.role} ${user.name}`);

    res.status(201).json(successResponse(productResponse, 'Product created successfully'));
  } catch (error) {
    console.error('Create product error:', error);
    res.status(500).json(errorResponse(createApiError('product', error.message), 'Failed to create product'));
  }
};

/**
 * PUT /products/:productId
 * Update product (owner only)
 */
exports.updateProduct = async (req, res) => {
  try {
    const user = req.user;
    const { productId } = req.params;
    const { name, description, price, stock, categoryId, images, weight, region, isLocal, isActive } = req.body;

    // Find product
    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json(
        errorResponse(
          [createApiError('product', 'Product not found')],
          'Product not found'
        )
      );
    }

    // Check ownership
    const isOwner = (user.role === 'retailer' && product.retailerId?.toString() === user.id) ||
                    (user.role === 'wholesaler' && product.wholesalerId?.toString() === user.id);
    
    if (!isOwner) {
      return res.status(403).json(
        errorResponse(
          [createApiError('auth', 'You can only update your own products')],
          'Forbidden'
        )
      );
    }

    // Update fields
    if (name !== undefined) product.name = name;
    if (description !== undefined) product.description = description;
    if (price !== undefined) product.price = parseFloat(price);
    if (stock !== undefined) product.stock = parseInt(stock);
    if (categoryId !== undefined) {
      // Verify category exists
      const category = await Category.findById(categoryId);
      if (!category) {
        return res.status(404).json(
          errorResponse(
            [createApiError('category', 'Category not found')],
            'Category not found'
          )
        );
      }
      product.categoryId = categoryId;
    }
    if (images !== undefined) product.images = images;
    if (weight !== undefined) product.weight = weight;
    if (region !== undefined) product.region = region;
    if (isLocal !== undefined) product.isLocal = isLocal;
    if (isActive !== undefined) product.isActive = isActive;

    await product.save();
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
      retailerId: product.retailerId?.toString(),
      wholesalerId: product.wholesalerId?.toString(),
      sourceType: product.sourceType,
      rating: product.rating || 0,
      reviewCount: product.reviewCount || 0,
      createdAt: product.createdAt.toISOString(),
    };

    console.log(`✅ Product updated: ${product.name}`);

    res.json(successResponse(productResponse, 'Product updated successfully'));
  } catch (error) {
    console.error('Update product error:', error);
    res.status(500).json(errorResponse(createApiError('product', error.message), 'Failed to update product'));
  }
};

/**
 * DELETE /products/:productId
 * Delete product (owner only)
 */
exports.deleteProduct = async (req, res) => {
  try {
    const user = req.user;
    const { productId } = req.params;

    // Find product
    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json(
        errorResponse(
          [createApiError('product', 'Product not found')],
          'Product not found'
        )
      );
    }

    // Check ownership
    const isOwner = (user.role === 'retailer' && product.retailerId?.toString() === user.id) ||
                    (user.role === 'wholesaler' && product.wholesalerId?.toString() === user.id);
    
    if (!isOwner) {
      return res.status(403).json(
        errorResponse(
          [createApiError('auth', 'You can only delete your own products')],
          'Forbidden'
        )
      );
    }

    // Soft delete (set isActive to false)
    product.isActive = false;
    await product.save();

    console.log(`✅ Product deleted: ${product.name}`);

    res.json(successResponse(null, 'Product deleted successfully'));
  } catch (error) {
    console.error('Delete product error:', error);
    res.status(500).json(errorResponse(createApiError('product', error.message), 'Failed to delete product'));
  }
};
