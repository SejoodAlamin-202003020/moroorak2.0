import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification.dart';
import 'push_notification_service.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  Stream<List<NotificationModel>>? _notificationsStream;

  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  Future<void> createNotification({
    required String userId,
    required String message,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });

      // Send push notification
      await PushNotificationService().sendPushNotification(
        userId: userId,
        title: 'Notification',
        body: message,
      );
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }
}
