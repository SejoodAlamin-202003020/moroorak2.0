import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<app_user.User?> signUp({
    required String fullName,
    required String licenseNumber,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'license_number': licenseNumber,
          'phone_number': phoneNumber,
        },
      );

      if (response.user != null) {
        // Insert user profile into users table
        await _supabase.from('users').insert({
          'id': response.user!.id,
          'full_name': fullName,
          'license_number': licenseNumber,
          'phone': phoneNumber,
          'email': email,
          'password': password,
        });

        return app_user.User(
          id: response.user!.id,
          fullName: fullName,
          licenseNumber: licenseNumber,
          phoneNumber: phoneNumber,
          email: email,
          password: password,
        );
      }
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
    return null;
  }

  Future<app_user.User?> signIn({
    required String identifier, // phone or email
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: identifier.contains('@') ? identifier : null,
        password: password,
      );

      if (response.user != null) {
        final profile = await _supabase
            .from('users')
            .select()
            .eq('id', response.user!.id)
            .single();

        return app_user.User.fromJson(profile);
      }
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
    return null;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  app_user.User? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      // Note: In a real app, you'd fetch the profile from DB
      // For simplicity, assuming profile is in user metadata
      return app_user.User(
        id: user.id,
        fullName: user.userMetadata?['full_name'] ?? '',
        licenseNumber: user.userMetadata?['license_number'] ?? '',
        phoneNumber: user.userMetadata?['phone_number'] ?? '',
        email: user.email ?? '',
        password: '', // Password not available from metadata
      );
    }
    return null;
  }

  Stream<app_user.User?> get userStream {
    return _supabase.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user != null) {
        return app_user.User(
          id: user.id,
          fullName: user.userMetadata?['full_name'] ?? '',
          licenseNumber: user.userMetadata?['license_number'] ?? '',
          phoneNumber: user.userMetadata?['phone_number'] ?? '',
          email: user.email ?? '',
          password: '', // Password not available from metadata
        );
      }
      return null;
    });
  }
}
