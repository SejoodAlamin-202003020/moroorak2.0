import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification.dart';

class InvestigatorNotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .order('created_at', ascending: false);

      return response
          .map<NotificationModel>((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('is_read', false)
          .order('created_at', ascending: false);

      return response
          .map<NotificationModel>((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load unread notifications: $e');
    }
  }

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });
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

  Future<void> markAllAsRead() async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true}).eq('is_read', false);
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  Future<void> createStatusUpdateNotification(
      String reportId, String oldStatus, String newStatus,
      {String? title, String? message}) async {
    try {
      final notificationTitle = title ?? 'Report Status Updated';
      final notificationMessage = message ??
          'Report $reportId status changed from $oldStatus to $newStatus';

      // Get the user_id from the report to notify the correct user
      final reportResponse = await _supabase
          .from('reports')
          .select('user_id, report_number')
          .eq('id', reportId)
          .single();

      final userId = reportResponse['user_id'];
      final reportNumber = reportResponse['report_number'];

      await createNotification(
        userId: userId,
        title: notificationTitle,
        message: notificationMessage.replaceAll(reportId, reportNumber),
      );

      // Note: Push notification functionality is handled by the mobile app
      // The notification is already created in the database above
    } catch (e) {
      throw Exception('Failed to create status update notification: $e');
    }
  }
}
