/**
 * Pagination utility functions
 */

const { defaultPageSize, maxPageSize } = require('../config/constants');

/**
 * Parse pagination parameters from query
 * @param {object} query - Express query object
 * @returns {object} Pagination parameters
 */
function parsePagination(query) {
  const page = Math.max(1, parseInt(query.page) || 1);
  const pageSize = Math.min(
    maxPageSize,
    Math.max(1, parseInt(query.pageSize) || defaultPageSize)
  );

  return {
    page,
    pageSize,
    skip: (page - 1) * pageSize,
    limit: pageSize,
  };
}

/**
 * Calculate pagination metadata
 * @param {number} totalItems - Total number of items
 * @param {number} page - Current page
 * @param {number} pageSize - Items per page
 * @returns {object} Pagination metadata
 */
function calculatePagination(totalItems, page, pageSize) {
  const totalPages = Math.ceil(totalItems / pageSize);

  return {
    currentPage: page,
    totalPages: totalPages,
    totalItems: totalItems,
    pageSize: pageSize,
    hasNext: page < totalPages,
    hasPrevious: page > 1,
  };
}

module.exports = {
  parsePagination,
  calculatePagination,
};

