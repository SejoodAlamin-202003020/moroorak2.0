import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report.dart';
import 'notification_service.dart';

class ReportService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Report>> getUserReports(String userId) async {
    try {
      final response = await _supabase
          .from('reports')
          .select(
              'id,user_id,reporter_name,report_number,my_plate_number,my_vehicle_type,my_vehicle_model,my_vehicle_color,other_plate_number,other_vehicle_type,other_vehicle_model,other_vehicle_color,is_owner,relation_to_owner,is_faulty,fault_percentage,my_license_number,other_license_number,my_search_certificate,other_search_certificate,insurance_covered,insurance_type,insurance_number,injuries,description,location,latitude,longitude,report_status,created_at,updated_at')
          .eq('user_id', userId)
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
      throw Exception('Failed to fetch reports: $e');
    }
  }

  Future<Report> submitReport({
    required String userId,
    required String myPlateNumber,
    required String myVehicleType,
    required String myVehicleModel,
    required String myVehicleColor,
    required String otherPlateNumber,
    required String otherVehicleType,
    required String otherVehicleModel,
    required String otherVehicleColor,
    required bool isOwner,
    String? relationToOwner,
    required bool isFaulty,
    required double faultPercentage,
    required String myLicenseNumber,
    required String otherLicenseNumber,
    required String mySearchCertificate,
    required String otherSearchCertificate,
    required bool insuranceCovered,
    String? insuranceType,
    String? insuranceNumber,
    required bool injuries,
    required String description,
    required String location,
    required List<String> photoUrls,
  }) async {
    try {
      final reportNumber =
          'HAQ-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

      // Parse location for lat/long
      double? latitude, longitude;
      if (location.contains(',')) {
        final parts = location.split(',');
        latitude = double.tryParse(parts[0].trim());
        longitude = double.tryParse(parts[1].trim());
      }

      // Get user info for reporter_name
      final userResponse = await _supabase
          .from('users')
          .select('full_name,email,phone')
          .eq('id', userId)
          .single();

      final response = await _supabase
          .from('reports')
          .insert({
            'user_id': userId,
            'reporter_name': userResponse['full_name'],
            'report_number': reportNumber,
            'my_plate_number': myPlateNumber,
            'my_vehicle_type': myVehicleType,
            'my_vehicle_model': myVehicleModel,
            'my_vehicle_color': myVehicleColor,
            'other_plate_number': otherPlateNumber,
            'other_vehicle_type': otherVehicleType,
            'other_vehicle_model': otherVehicleModel,
            'other_vehicle_color': otherVehicleColor,
            'is_owner': isOwner,
            'relation_to_owner': relationToOwner,
            'is_faulty': isFaulty,
            'fault_percentage': faultPercentage,
            'my_license_number': myLicenseNumber,
            'other_license_number': otherLicenseNumber,
            'my_search_certificate': mySearchCertificate,
            'other_search_certificate': otherSearchCertificate,
            'insurance_covered': insuranceCovered,
            'insurance_type': insuranceType,
            'insurance_number': insuranceNumber,
            'injuries': injuries,
            'description': description,
            'location': location,
            'latitude': latitude,
            'longitude': longitude,
            'report_status': 'pending',
          })
          .select()
          .single();

      final report = Report.fromJson(response);

      // Insert photos into report_images table
      if (photoUrls.isNotEmpty) {
        final photoInserts = photoUrls
            .map((url) => {
                  'report_id': report.id,
                  'image_url': url,
                })
            .toList();
        await _supabase.from('report_images').insert(photoInserts);
        report.photoUrls.addAll(photoUrls);
      }

      // Create notification for the user
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'message':
            'Your report ${report.reportNumber} has been submitted successfully.',
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });

      return report;
    } catch (e) {
      throw Exception('Failed to submit report: $e');
    }
  }

  Future<void> updateReportStatus(String reportId, String status,
      {String? notes}) async {
    try {
      final updateData = {
        'report_status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (notes != null) {
        updateData['notes'] = notes;
      }
      await _supabase.from('reports').update(updateData).eq('id', reportId);

      // Fetch the report to get user_id and report_number for notification
      final reportResponse = await _supabase
          .from('reports')
          .select('user_id, report_number')
          .eq('id', reportId)
          .single();

      final userId = reportResponse['user_id'];
      final reportNumber = reportResponse['report_number'];

      // Create notification for the user
      await NotificationService().createNotification(
        userId: userId,
        message: 'Your report $reportNumber has been $status.',
      );

      // Also create notification for investigators about new report
      if (status == 'pending') {
        // Get all investigators
        final investigators = await _supabase
            .from('investigators')
            .select('id')
            .neq('id', ''); // Get all

        for (final investigator in investigators) {
          await _supabase.from('notifications').insert({
            'user_id': investigator['id'],
            'title': 'New Report Submitted',
            'message':
                'A new report $reportNumber has been submitted and needs review.',
            'created_at': DateTime.now().toIso8601String(),
            'is_read': false,
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to update report status: $e');
    }
  }
}
