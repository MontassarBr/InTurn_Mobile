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
      final response = await ApiService().post('/users/login', {
        'email': email,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;

      if (data['token'] == null) {
        throw Exception('No token received from server');
      }

      final token = data['token'] as String;
      final user = data['user'] as Map<String, dynamic>;
      final userType = user['userType'] as String;
      final userId = user['userID'].toString();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);
      await prefs.setString(AppConstants.userTypeKey, userType);
      await prefs.setString(AppConstants.userIdKey, userId);

      _setStatus(AuthStatus.authenticated);

      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      final message = e.toString();
      if (message.contains('401') || message.toLowerCase().contains('invalid') || message.toLowerCase().contains('unauthorized')) {
        _errorMessage = 'Invalid email or password. Please try again.';
      } else if (message.contains('Connection')) {
        _errorMessage = 'Cannot reach server. Check your internet connection.';
      } else {
        _errorMessage = 'Login failed. Please try again.';
      }
      _setStatus(AuthStatus.error);
    }
  }

  Future<void> register({
    required Map<String, dynamic> payload,
    required BuildContext context,
  }) async {
    _setStatus(AuthStatus.loading);
    try {
      // Ensure required fields are present
      if (!payload.containsKey('email') || !payload.containsKey('password') || !payload.containsKey('userType')) {
        throw Exception('Email, password, and userType are required');
      }

      final response = await ApiService().post('/users/register', payload);
      final data = response.data as Map<String, dynamic>;

      if (data['token'] == null) throw Exception('No token returned after registration');

      final token = data['token'] as String;
      final user = data['user'] as Map<String, dynamic>;
      final userType = user['userType'] as String;
      final userId = user['userID'].toString();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);
      await prefs.setString(AppConstants.userTypeKey, userType);
      await prefs.setString(AppConstants.userIdKey, userId);

      _setStatus(AuthStatus.authenticated);

      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
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
