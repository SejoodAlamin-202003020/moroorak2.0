import 'package:flutter/material.dart';
import '../models/report.dart';
import '../models/notification.dart';
import '../services/investigator_report_service.dart';
import '../services/investigator_notification_service.dart';

class InvestigatorReportProvider with ChangeNotifier {
  final InvestigatorReportService _reportService = InvestigatorReportService();
  final InvestigatorNotificationService _notificationService =
      InvestigatorNotificationService();

  List<Report> _reports = [];
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<Report> get reports => _reports;
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final reports = await _reportService.getAllReports();
      final notifications = await _notificationService.getAllNotifications();
      _reports = reports;
      _notifications = notifications;
    } catch (e) {
      // Handle error if needed
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateReportStatus(String reportId, String status,
      {String? notes}) async {
    try {
      await _reportService.updateReportStatus(reportId, status, notes: notes);
      // Reload data to refresh counters
      await loadData();
    } catch (e) {
      throw e;
    }
  }

  Future<void> searchReports(String query) async {
    if (query.isEmpty) {
      await loadData();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final results = await _reportService.searchReports(query);
      _reports = results;
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
