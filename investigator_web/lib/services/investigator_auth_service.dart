import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/investigator.dart';

class InvestigatorAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Investigator?> signIn({
    required String investigatorId,
    required String password,
  }) async {
    try {
      // Query the investigators table to find the user by id_number
      final response = await _supabase
          .from('investigators')
          .select()
          .eq('id_number', investigatorId)
          .single();

      if (response == null) {
        throw Exception('Invalid investigator ID');
      }

      final investigator = Investigator.fromJson(response);

      // Verify password (in production, this should be hashed)
      if (investigator.password != password) {
        throw Exception('Invalid password');
      }

      // Store investigator data in shared preferences for persistence
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id_number', investigatorId);
      await prefs.setString('investigator_data', jsonEncode(response));

      return investigator;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> signOut() async {
    // Clear stored investigator data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id_number');
    await prefs.remove('investigator_data');
    await _supabase.auth.signOut();
  }

  Future<Investigator?> getCurrentInvestigator() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final investigatorId = prefs.getString('investigator_id');
      final investigatorData = prefs.getString('investigator_data');

      if (investigatorId != null && investigatorData != null) {
        // Parse the stored data back to investigator object
        final data = jsonDecode(investigatorData) as Map<String, dynamic>;
        return Investigator.fromJson(data);
      }
    } catch (e) {
      // If there's an error retrieving stored data, return null
      return null;
    }
    return null;
  }

  Stream<Investigator?> get investigatorStream {
    // Mock stream for now - in production, this would listen to auth state changes
    return Stream.value(null);
  }
}
