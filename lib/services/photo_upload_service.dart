import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhotoUploadService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<String>> uploadPhotos(List<File> photos, String reportId) async {
    final List<String> photoUrls = [];
    for (final photo in photos) {
      final fileName =
          '${reportId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'reports/$fileName';
      await _supabase.storage.from('report-photos').upload(filePath, photo);
      final publicUrl =
          _supabase.storage.from('report-photos').getPublicUrl(filePath);
      photoUrls.add(publicUrl);
    }
    return photoUrls;
  }
}
