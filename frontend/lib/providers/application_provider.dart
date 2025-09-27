import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/application.dart';

class ApplicationProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<Application> _applications = [];
  bool _loading = false;
  String? _error;

  List<Application> get applications => _applications;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchMyApplications() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get<List<dynamic>>('/applications/student');
      final data = response.data ?? [];
      _applications = data.map((e) => Application.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      _error = 'Failed to load applications';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
