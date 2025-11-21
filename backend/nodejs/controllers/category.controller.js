const Category = require('../models/Category');
const { successResponse, errorResponse, createApiError } = require('../utils/response.util');

/**
 * Category Controller
 * Matching Dart CategoryApiService methods
 */

/**
 * GET /categories
 * Get all categories
 * Matching: CategoryApiService.getCategories()
 */
exports.getCategories = async (req, res) => {
  try {
    const categories = await Category.find().sort({ name: 1 }).lean();

    const categoriesResponse = categories.map(cat => ({
      id: cat._id.toString(),
      name: cat.name,
      slug: cat.slug,
      description: cat.description,
      imageUrl: cat.imageUrl,
      productCount: cat.productCount || 0,
    }));

    res.json(successResponse(categoriesResponse));
  } catch (error) {
    console.error('Get categories error:', error);
    res.status(500).json(errorResponse(createApiError('category', error.message), 'Failed to get categories'));
  }
};

/**
 * GET /categories/:categoryId
 * Get category by ID
 * Matching: CategoryApiService.getCategoryById()
 */
exports.getCategoryById = async (req, res) => {
  try {
    const { categoryId } = req.params;

    const category = await Category.findById(categoryId).lean();

    if (!category) {
      return res.status(404).json(
        errorResponse(
          [createApiError('category', 'Category not found')],
          'Category not found'
        )
      );
    }

    const categoryResponse = {
      id: category._id.toString(),
      name: category.name,
      slug: category.slug,
      description: category.description,
      imageUrl: category.imageUrl,
      productCount: category.productCount || 0,
    };

    res.json(successResponse(categoryResponse));
  } catch (error) {
    console.error('Get category error:', error);
    res.status(500).json(errorResponse(createApiError('category', error.message), 'Failed to get category'));
  }
};
