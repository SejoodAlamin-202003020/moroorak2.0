import 'package:flutter/material.dart';
import '../models/investigator.dart';
import '../services/investigator_auth_service.dart';

class InvestigatorAuthProvider with ChangeNotifier {
  final InvestigatorAuthService _authService = InvestigatorAuthService();
  Investigator? _investigator;
  bool _isLoading = false;

  Investigator? get investigator => _investigator;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _investigator != null;

  InvestigatorAuthProvider() {
    _init();
  }

  void _init() async {
    _investigator = await _authService.getCurrentInvestigator();
    notifyListeners();
  }

  Future<void> signIn({
    required String investigatorId,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _investigator = await _authService.signIn(
        investigatorId: investigatorId,
        password: password,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _investigator = null;
    notifyListeners();
  }
}
