import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/saved_internship.dart';
import '../models/internship.dart';

class SavedInternshipProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<SavedInternship> _savedInternships = [];
  bool _loading = false;
  String? _error;

  List<SavedInternship> get savedInternships => _savedInternships;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchSavedInternships() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/saved-internships');
      _savedInternships = (response.data as List)
          .map((item) => SavedInternship.fromJson(item))
          .toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load saved internships: ${e.toString()}';
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> saveInternship(int internshipID) async {
    try {
      await _api.post('/saved-internships', {
        'internshipID': internshipID,
      });
      
      // Refresh the saved internships list
      await fetchSavedInternships();
      return true;
    } catch (e) {
      _error = 'Failed to save internship: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> unsaveInternship(int internshipID) async {
    try {
      await _api.delete('/saved-internships/$internshipID');
      
      // Refresh the saved internships list
      await fetchSavedInternships();
      return true;
    } catch (e) {
      _error = 'Failed to unsave internship: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  bool isInternshipSaved(int internshipID) {
    return _savedInternships.any((saved) => saved.internshipID == internshipID);
  }
}
