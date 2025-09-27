import 'package:flutter/material.dart';
import '../models/internship.dart';
import '../services/api_service.dart';

class InternshipProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<Internship> _internships = [];
  bool _loading = false;
  String? _error;

  List<Internship> get internships => _internships;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchInternships({Map<String, dynamic>? filters}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get<List<dynamic>>('/internships', queryParameters: filters);
      final data = response.data ?? [];
      _internships = data.map((e) => Internship.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      _error = 'Failed to load internships';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
