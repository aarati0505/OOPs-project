const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notification.controller');
const { authenticateToken, requireAuth } = require('../middleware/auth.middleware');

// GET /notifications
router.get('/', authenticateToken, requireAuth, notificationController.getNotifications);

// POST /notifications/read/:notificationId
router.post('/read/:notificationId', authenticateToken, requireAuth, notificationController.markNotificationRead);

// POST /notifications/read-all
router.post('/read-all', authenticateToken, requireAuth, notificationController.markAllNotificationsRead);

// DELETE /notifications/:notificationId
router.delete('/:notificationId', authenticateToken, requireAuth, notificationController.deleteNotification);

module.exports = router;

