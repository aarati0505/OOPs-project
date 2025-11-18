// Products Controller

const Product = require('../models/Product');
const { calculateDistance } = require('../utils/location.utils');

// Get Products with filters
exports.getProducts = async (req, res, next) => {
  try {
    const {
      page = 1,
      pageSize = 20,
      category,
      minPrice,
      maxPrice,
      search,
      inStock,
      region,
      latitude,
      longitude,
      maxDistance,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = req.query;

    // Build query
    const query = {};

    if (category) query.category = category;
    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = parseFloat(minPrice);
      if (maxPrice) query.price.$lte = parseFloat(maxPrice);
    }
    if (inStock !== undefined) query.isAvailable = inStock === 'true';
    if (region) query.region = region;
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { category: { $regex: search, $options: 'i' } },
      ];
    }

    // Calculate pagination
    const skip = (parseInt(page) - 1) * parseInt(pageSize);
    const limit = parseInt(pageSize);

    // Sort
    const sort = {};
    sort[sortBy] = sortOrder === 'asc' ? 1 : -1;

    // Execute query
    const [products, totalItems] = await Promise.all([
      Product.find(query)
        .sort(sort)
        .skip(skip)
        .limit(limit)
        .populate('retailerId', 'name businessName')
        .populate('wholesalerId', 'name businessName'),
      Product.countDocuments(query),
    ]);

    // Calculate distance if location provided
    let productsWithDistance = products;
    if (latitude && longitude) {
      productsWithDistance = products.map((product) => {
        if (product.shopLocation) {
          const distance = calculateDistance(
            parseFloat(latitude),
            parseFloat(longitude),
            product.shopLocation.latitude,
            product.shopLocation.longitude
          );
          product.distanceFromUser = distance;
        }
        return product;
      });

      // Filter by max distance if provided
      if (maxDistance) {
        productsWithDistance = productsWithDistance.filter(
          (p) => !p.distanceFromUser || p.distanceFromUser <= parseFloat(maxDistance)
        );
      }

      // Sort by distance
      productsWithDistance.sort((a, b) => {
        const distA = a.distanceFromUser || Infinity;
        const distB = b.distanceFromUser || Infinity;
        return distA - distB;
      });
    }

    const totalPages = Math.ceil(totalItems / limit);

    // Format response to match Flutter PaginatedResponse
    res.json({
      success: true,
      data: {
        data: productsWithDistance.map((p) => formatProduct(p)),
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

// Get Product by ID
exports.getProductById = async (req, res, next) => {
  try {
    const { productId } = req.params;

    const product = await Product.findById(productId)
      .populate('retailerId', 'name businessName location')
      .populate('wholesalerId', 'name businessName location');

    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found',
      });
    }

    res.json({
      success: true,
      data: formatProduct(product),
    });
  } catch (error) {
    next(error);
  }
};

// Search Products
exports.searchProducts = async (req, res, next) => {
  try {
    const { q, ...filters } = req.query;
    
    // Use same logic as getProducts but with search query
    req.query.search = q;
    return exports.getProducts(req, res, next);
  } catch (error) {
    next(error);
  }
};

// Get Products by Category
exports.getProductsByCategory = async (req, res, next) => {
  try {
    const { categoryId } = req.params;
    
    req.query.category = categoryId;
    return exports.getProducts(req, res, next);
  } catch (error) {
    next(error);
  }
};

// Get Popular Products
exports.getPopularProducts = async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 10;

    // Get products sorted by sales/popularity
    const products = await Product.find({ isAvailable: true })
      .sort({ salesCount: -1, rating: -1 })
      .limit(limit)
      .populate('retailerId', 'name businessName');

    res.json({
      success: true,
      data: products.map((p) => formatProduct(p)),
    });
  } catch (error) {
    next(error);
  }
};

// Get New Products
exports.getNewProducts = async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 10;

    const products = await Product.find({ isAvailable: true })
      .sort({ createdAt: -1 })
      .limit(limit)
      .populate('retailerId', 'name businessName');

    res.json({
      success: true,
      data: products.map((p) => formatProduct(p)),
    });
  } catch (error) {
    next(error);
  }
};

// Get Region-Specific Products
exports.getRegionSpecificProducts = async (req, res, next) => {
  try {
    const { region } = req.query;

    if (!region) {
      return res.status(400).json({
        success: false,
        message: 'Region parameter is required',
      });
    }

    req.query.region = region;
    return exports.getProducts(req, res, next);
  } catch (error) {
    next(error);
  }
};

// Helper function to format product response
function formatProduct(product) {
  return {
    id: product._id.toString(),
    name: product.name,
    weight: product.weight,
    cover: product.cover,
    images: product.images,
    price: product.price,
    mainPrice: product.mainPrice,
    category: product.category,
    description: product.description,
    stockQuantity: product.stockQuantity,
    isAvailable: product.isAvailable,
    availabilityDate: product.availabilityDate?.toISOString(),
    isRegionSpecific: product.isRegionSpecific,
    region: product.region,
    retailerId: product.retailerId?._id?.toString(),
    retailerName: product.retailerId?.businessName || product.retailerId?.name,
    wholesalerId: product.wholesalerId?._id?.toString(),
    wholesalerName: product.wholesalerId?.businessName || product.wholesalerId?.name,
    isViaWholesaler: product.isViaWholesaler,
    shopLocation: product.shopLocation,
    distanceFromUser: product.distanceFromUser,
    createdAt: product.createdAt.toISOString(),
    updatedAt: product.updatedAt.toISOString(),
  };
}

