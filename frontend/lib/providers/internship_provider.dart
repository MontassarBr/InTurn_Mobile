import 'package:flutter/material.dart';
import '../models/internship.dart';
import '../services/api_service.dart';

class InternshipProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<Internship> _internships = [];
  Internship? _selectedInternship;
  bool _loading = false;
  String? _error;

  List<Internship> get internships => _internships;
  Internship? get selectedInternship => _selectedInternship;
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
      if (e.toString().contains('403')) {
        _error = 'Access denied. Please check your login status.';
      } else if (e.toString().contains('404')) {
        _error = 'Internships service not available.';
      } else if (e.toString().contains('Connection')) {
        _error = 'Cannot connect to server. Please check your internet connection.';
        // Load mock data for testing when server is not available
        _loadMockInternships();
      } else {
        _error = 'Failed to load internships: ${e.toString()}';
      }
      print('Internships fetch error: $e'); // Debug log
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchInternshipById(int id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get<Map<String, dynamic>>('/internships/$id');
      if (response.data != null) {
        _selectedInternship = Internship.fromJson(response.data!);
      }
    } catch (e) {
      _error = 'Failed to load internship details: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearSelectedInternship() {
    _selectedInternship = null;
    notifyListeners();
  }

  Future<bool> createInternship(Map<String, dynamic> internshipData) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.post('/internships', internshipData);
      await fetchInternships(); // Refresh the list
      return true;
    } catch (e) {
      _error = 'Failed to create internship: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateInternship(int internshipId, Map<String, dynamic> internshipData) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.put('/internships/$internshipId', internshipData);
      await fetchInternships(); // Refresh the list
      return true;
    } catch (e) {
      _error = 'Failed to update internship: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteInternship(int internshipId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.delete('/internships/$internshipId');
      await fetchInternships(); // Refresh the list
      return true;
    } catch (e) {
      _error = 'Failed to delete internship: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _loadMockInternships() {
    _internships = [
      Internship(
        internshipID: 1,
        companyID: 1,
        title: 'Software Development Intern',
        location: 'Remote',
        startDate: '2024-06-01',
        endDate: '2024-08-31',
        minSalary: 2000.0,
        maxSalary: 3000.0,
        description: 'Join our development team to build amazing applications.',
        payment: 'paid',
        workArrangement: 'Remote',
        workTime: 'Full Time',
        status: 'Published',
        companyName: 'Tech Solutions Inc',
        industry: 'Technology',
      ),
      Internship(
        internshipID: 2,
        companyID: 2,
        title: 'Marketing Intern',
        location: 'New York, NY',
        startDate: '2024-07-01',
        endDate: '2024-09-30',
        minSalary: 1500.0,
        maxSalary: 2000.0,
        description: 'Help us create engaging marketing campaigns.',
        payment: 'paid',
        workArrangement: 'Hybrid',
        workTime: 'Part Time',
        status: 'Published',
        companyName: 'Marketing Pro',
        industry: 'Marketing',
      ),
    ];
    _error = null; // Clear error when loading mock data
  }
}
