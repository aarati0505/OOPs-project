const Notification = require('../models/Notification');
const { successResponse, errorResponse, createApiError } = require('../utils/response.util');
const { parsePagination, calculatePagination } = require('../utils/pagination.util');

/**
 * Notification Controller
 * Matching Dart NotificationApiService methods
 */

/**
 * GET /notifications
 * Get notifications
 * Matching: NotificationApiService.getNotifications()
 */
exports.getNotifications = async (req, res) => {
  try {
    const pagination = parsePagination(req.query);
    const { unreadOnly } = req.query;

    const query = { userId: req.user._id };
    if (unreadOnly === 'true') {
      query.isRead = false;
    }

    const [notifications, totalItems] = await Promise.all([
      Notification.find(query)
        .sort({ createdAt: -1 })
        .skip(pagination.skip)
        .limit(pagination.limit)
        .lean(),
      Notification.countDocuments(query),
    ]);

    // Format notifications (matching Dart Notification structure)
    const notificationsResponse = notifications.map(notif => ({
      id: notif._id.toString(),
      title: notif.title,
      message: notif.message,
      type: notif.type,
      isRead: notif.isRead,
      createdAt: notif.createdAt.toISOString(),
      data: notif.data,
    }));

    const paginationMeta = calculatePagination(totalItems, pagination.page, pagination.pageSize);

    res.json(successResponse({
      data: notificationsResponse,
      ...paginationMeta,
    }));
  } catch (error) {
    console.error('Get notifications error:', error);
    res.status(500).json(errorResponse(createApiError('notification', error.message), 'Failed to get notifications'));
  }
};

/**
 * POST /notifications/read/:notificationId
 * Mark notification as read
 * Matching: NotificationApiService.markNotificationRead()
 */
exports.markNotificationRead = async (req, res) => {
  try {
    const { notificationId } = req.params;

    const notification = await Notification.findOneAndUpdate(
      { _id: notificationId, userId: req.user._id },
      { isRead: true },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json(
        errorResponse(
          [createApiError('notification', 'Notification not found')],
          'Notification not found'
        )
      );
    }

    res.json(successResponse(null, 'Notification marked as read'));
  } catch (error) {
    console.error('Mark notification read error:', error);
    res.status(500).json(errorResponse(createApiError('notification', error.message), 'Failed to mark notification as read'));
  }
};

/**
 * POST /notifications/read-all
 * Mark all notifications as read
 * Matching: NotificationApiService.markAllNotificationsRead()
 */
exports.markAllNotificationsRead = async (req, res) => {
  try {
    await Notification.updateMany(
      { userId: req.user._id, isRead: false },
      { isRead: true }
    );

    res.json(successResponse(null, 'All notifications marked as read'));
  } catch (error) {
    console.error('Mark all notifications read error:', error);
    res.status(500).json(errorResponse(createApiError('notification', error.message), 'Failed to mark all notifications as read'));
  }
};

/**
 * DELETE /notifications/:notificationId
 * Delete notification
 * Matching: NotificationApiService.deleteNotification()
 */
exports.deleteNotification = async (req, res) => {
  try {
    const { notificationId } = req.params;

    const notification = await Notification.findOneAndDelete({
      _id: notificationId,
      userId: req.user._id,
    });

    if (!notification) {
      return res.status(404).json(
        errorResponse(
          [createApiError('notification', 'Notification not found')],
          'Notification not found'
        )
      );
    }

    res.json(successResponse(null, 'Notification deleted'));
  } catch (error) {
    console.error('Delete notification error:', error);
    res.status(500).json(errorResponse(createApiError('notification', error.message), 'Failed to delete notification'));
  }
};
