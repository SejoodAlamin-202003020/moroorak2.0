import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  app_user.User? _user;
  bool _isLoading = false;

  app_user.User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _user = _authService.getCurrentUser();
    _authService.userStream.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<int> getUserReportCount(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('reports')
          .select('id')
          .eq('user_id', userId);
      return response.length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> signUp({
    required String fullName,
    required String licenseNumber,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.signUp(
        fullName: fullName,
        licenseNumber: licenseNumber,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({
    required String identifier,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.signIn(
        identifier: identifier,
        password: password,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
