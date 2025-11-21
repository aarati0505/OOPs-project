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
