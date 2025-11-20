import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/services/api_service.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiService _apiService;

  NotificationService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Get all notifications for business user
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _apiService.get(
        '/business/notifications',
        token: token,
      );

      if (response == null) {
        return [];
      }

      // Handle both direct array and nested data structure
      final List<dynamic> notificationsList;
      if (response is List) {
        notificationsList = response;
      } else if (response is Map && response['data'] != null) {
        notificationsList = response['data'] as List;
      } else if (response is Map && response['notifications'] != null) {
        notificationsList = response['notifications'] as List;
      } else {
        return [];
      }

      return notificationsList
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      rethrow;
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final notifications = await getNotifications();
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      await _apiService.put(
        '/business/notifications/$notificationId/read',
        body: {},
        token: token,
      );
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      await _apiService.put(
        '/business/notifications/mark-all-read',
        body: {},
        token: token,
      );
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      rethrow;
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      await _apiService.delete(
        '/business/notifications/$notificationId',
        token: token,
      );
    } catch (e) {
      print('❌ Error deleting notification: $e');
      rethrow;
    }
  }
}

