import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

enum AuthStatus { idle, loading, authenticated, error }

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    _setStatus(AuthStatus.loading);
    try {
      final response = await ApiService().post('/auth/login', {
        'email': email,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final userType = data['userType'] as String;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);
      await prefs.setString(AppConstants.userTypeKey, userType);

      _setStatus(AuthStatus.authenticated);

      if (context.mounted) {
        if (userType == AppConstants.studentType) {
          Navigator.of(context).pushReplacementNamed('/student-dashboard');
        } else {
          Navigator.of(context).pushReplacementNamed('/company-dashboard');
        }
      }
    } catch (e) {
      _errorMessage = 'Login failed. ${e.toString()}';
      _setStatus(AuthStatus.error);
    }
  }

  Future<void> register({
    required Map<String, dynamic> payload,
    required BuildContext context,
  }) async {
    _setStatus(AuthStatus.loading);
    try {
      await ApiService().post('/auth/register', payload);
      _setStatus(AuthStatus.idle);
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      _errorMessage = 'Registration failed. ${e.toString()}';
      _setStatus(AuthStatus.error);
    }
  }

  void logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _setStatus(AuthStatus.idle);
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  void _setStatus(AuthStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }
}
