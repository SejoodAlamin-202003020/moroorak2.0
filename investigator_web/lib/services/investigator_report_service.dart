import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report.dart';
import 'investigator_notification_service.dart';

class InvestigatorReportService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Report>> getAllReports() async {
    try {
      final response = await _supabase
          .from('reports')
          .select(
              'id,user_id,reporter_name,report_number,my_plate_number,my_vehicle_type,my_vehicle_model,my_vehicle_color,other_plate_number,other_vehicle_type,other_vehicle_model,other_vehicle_color,is_owner,relation_to_owner,is_faulty,fault_percentage,my_license_number,other_license_number,my_search_certificate,other_search_certificate,insurance_covered,insurance_type,insurance_number,injuries,description,location,latitude,longitude,report_status,created_at,updated_at')
          .order('created_at', ascending: false);

      final reports = <Report>[];
      for (final json in response) {
        final report = Report.fromJson(json);
        // Fetch photos for each report
        final photos = await _supabase
            .from('report_images')
            .select('image_url')
            .eq('report_id', report.id);
        report.photoUrls.addAll(photos.map((p) => p['image_url'] as String));
        reports.add(report);
      }
      return reports;
    } catch (e) {
      throw Exception('Failed to load reports: $e');
    }
  }

  Future<List<Report>> getReportsByStatus(String status) async {
    try {
      final response = await _supabase
          .from('reports')
          .select(
              'id,user_id,reporter_name,report_number,my_plate_number,my_vehicle_type,my_vehicle_model,my_vehicle_color,other_plate_number,other_vehicle_type,other_vehicle_model,other_vehicle_color,is_owner,relation_to_owner,is_faulty,fault_percentage,my_license_number,other_license_number,my_search_certificate,other_search_certificate,insurance_covered,insurance_type,insurance_number,injuries,description,location,latitude,longitude,report_status,created_at,updated_at')
          .eq('report_status', status)
          .order('created_at', ascending: false);

      final reports = <Report>[];
      for (final json in response) {
        final report = Report.fromJson(json);
        // Fetch photos for each report
        final photos = await _supabase
            .from('report_images')
            .select('image_url')
            .eq('report_id', report.id);
        report.photoUrls.addAll(photos.map((p) => p['image_url'] as String));
        reports.add(report);
      }
      return reports;
    } catch (e) {
      throw Exception('Failed to load reports by status: $e');
    }
  }

  Future<List<Report>> searchReports(String query) async {
    try {
      final response = await _supabase
          .from('reports')
          .select(
              'id,user_id,reporter_name,report_number,my_plate_number,my_vehicle_type,my_vehicle_model,my_vehicle_color,other_plate_number,other_vehicle_type,other_vehicle_model,other_vehicle_color,is_owner,relation_to_owner,is_faulty,fault_percentage,my_license_number,other_license_number,my_search_certificate,other_search_certificate,insurance_covered,insurance_type,insurance_number,injuries,description,location,latitude,longitude,report_status,created_at,updated_at')
          .or('report_number.ilike.%$query%,my_plate_number.ilike.%$query%,other_plate_number.ilike.%$query%,reporter_name.ilike.%$query%')
          .order('created_at', ascending: false);

      final reports = <Report>[];
      for (final json in response) {
        final report = Report.fromJson(json);
        // Fetch photos for each report
        final photos = await _supabase
            .from('report_images')
            .select('image_url')
            .eq('report_id', report.id);
        report.photoUrls.addAll(photos.map((p) => p['image_url'] as String));
        reports.add(report);
      }
      return reports;
    } catch (e) {
      throw Exception('Failed to search reports: $e');
    }
  }

  Future<void> updateReportStatus(String reportId, String status,
      {String? notes}) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      // Get the current report to check the old status and get user_id for notification
      final reportResponse = await _supabase
          .from('reports')
          .select('report_status, user_id, report_number, investigator_id')
          .eq('id', reportId)
          .single();

      final oldStatus = reportResponse['report_status'] as String;
      final userId = reportResponse['user_id'] as String;
      final reportNumber = reportResponse['report_number'] as String;
      final investigatorId = reportResponse['investigator_id'] as String?;

      // Get investigator name
      final investigatorResponse = await _supabase
          .from('investigators')
          .select('name')
          .eq('id', currentUser.id)
          .single();
      final investigatorName = investigatorResponse['name'] as String;

      // Update the report status and set investigator_id if not set
      Map<String, dynamic> updateData = {
        'report_status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (investigatorId == null) {
        updateData['investigator_id'] = currentUser.id;
      }

      await _supabase.from('reports').update(updateData).eq('id', reportId);

      // Create notification for the user about the status change
      final notificationService = InvestigatorNotificationService();
      await notificationService.createStatusUpdateNotification(
          reportId, oldStatus, status,
          title: 'Report Status Updated',
          message:
              'Your report $reportNumber has been $status by $investigatorName.');
    } catch (e) {
      throw Exception('Failed to update report status: $e');
    }
  }

  Future<Report> getReportById(String reportId) async {
    try {
      final response = await _supabase
          .from('reports')
          .select(
              'id,user_id,reporter_name,report_number,my_plate_number,my_vehicle_type,my_vehicle_model,my_vehicle_color,other_plate_number,other_vehicle_type,other_vehicle_model,other_vehicle_color,is_owner,relation_to_owner,is_faulty,fault_percentage,my_license_number,other_license_number,my_search_certificate,other_search_certificate,insurance_covered,insurance_type,insurance_number,injuries,description,location,latitude,longitude,report_status,created_at,updated_at')
          .eq('id', reportId)
          .single();

      final report = Report.fromJson(response);
      // Fetch photos for the report
      final photos = await _supabase
          .from('report_images')
          .select('image_url')
          .eq('report_id', report.id);
      report.photoUrls.addAll(photos.map((p) => p['image_url'] as String));

      return report;
    } catch (e) {
      throw Exception('Failed to load report: $e');
    }
  }

  Future<void> dispatchPatrol(String reportId, String location) async {
    try {
      // Get report details for notification
      final report = await getReportById(reportId);

      // Create a notification for the user who submitted the report
      await _supabase.from('notifications').insert({
        'user_id': report.userId,
        'title': 'Patrol Dispatched',
        'message':
            'A patrol has been dispatched to location: $location for your report ${report.reportNumber}',
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });

      // Update report with patrol dispatch note
      final updatedNotes =
          '${report.notes ?? ''}\n\nPatrol dispatched to: $location at ${DateTime.now()}';

      await updateReportStatus(reportId, report.reportStatus,
          notes: updatedNotes);
    } catch (e) {
      throw Exception('Failed to dispatch patrol: $e');
    }
  }
}
