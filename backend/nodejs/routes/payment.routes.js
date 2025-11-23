const express = require('express');
const router = express.Router();
const { createOrder } = require('../controllers/payment.controller');

// POST /v1/payment/create-order
router.post('/create-order', createOrder);

module.exports = router;
