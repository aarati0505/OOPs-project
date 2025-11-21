const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/category.controller');
const { authenticateToken } = require('../middleware/auth.middleware');

// GET /categories
router.get('/', authenticateToken, categoryController.getCategories);

// GET /categories/:categoryId
router.get('/:categoryId', authenticateToken, categoryController.getCategoryById);

module.exports = router;

