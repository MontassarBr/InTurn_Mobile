import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/education.dart';
import '../models/experience.dart';

class StudentProfileProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  // Basic fields from database
  String firstName = '';
  String lastName = '';
  String? title;
  String? about;
  String? cvFile;
  String? profilePic; // Keep this for compatibility
  bool openToWork = false;
  String? phone;
  
  // University information
  String? university;
  String? degree;
  int? graduationYear;
  double? gpa;
  
  // Social links
  String? portfolioUrl;
  String? linkedinUrl;
  String? githubUrl;

  List<Education> education = [];
  List<String> skills = [];
  List<Experience> experience = [];

  bool loading = false;
  String? error;

  Future<void> addSkill(String skill) async {
    loading = true;
    notifyListeners();
    try {
      await _api.post('/students/skills', { 'skill': skill });
      await fetchProfile();
    } catch (_) {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSkill(String skill) async {
    loading = true;
    notifyListeners();
    try {
      await _api.delete('/students/skills/$skill');
      await fetchProfile();
    } catch (_) {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addEducation(Education edu) async {
    loading = true;
    notifyListeners();
    try {
      await _api.post('/students/education', {
        'institution': edu.institution,
        'diploma': edu.diploma,
        'location': edu.location,
        'startDate': edu.startDate,
        'endDate': edu.endDate,
      });
      await fetchProfile();
    } catch (_) {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEducation(String institution, String diploma) async {
    loading = true;
    notifyListeners();
    try {
      await _api.delete('/students/education', queryParameters: {
        'institution': institution,
        'diploma': diploma,
      });
      await fetchProfile();
    } catch (_) {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addExperience(Experience exp) async {
    loading = true;
    notifyListeners();
    try {
      await _api.post('/students/experience', {
        'title': exp.title,
        'startDate': exp.startDate,
        'endDate': exp.endDate,
        'employmentType': exp.employmentType,
        'companyName': exp.companyName,
        'description': exp.description,
      });
      await fetchProfile();
    } catch (e) {
      print('Error adding experience: $e'); // Debug log
      loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteExperience(int id) async {
    loading = true;
    notifyListeners();
    try {
      await _api.delete('/students/experience/$id');
      await fetchProfile();
    } catch (e) {
      print('Error deleting experience: $e'); // Debug log
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      print('Updating profile with data: $data'); // Debug log
      await _api.put('/students/me', data);
      await fetchProfile();
      return true;
    } catch (e) {
      print('Profile update error: $e'); // Debug log
      error = 'Failed to update profile: $e';
      loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchProfile() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      print('Fetching profile...'); // Debug log
      final response = await _api.get<Map<String, dynamic>>('/students/full');
      print('Profile response: ${response.data}'); // Debug log
      final data = response.data!;
      
      print('Parsing basic fields...'); // Debug log
      firstName = data['firstName'] ?? '';
      lastName = data['lastName'] ?? '';
      title = data['title'];
      about = data['about'];
      cvFile = data['cvFile'];
      profilePic = data['profilePic']; // Keep for compatibility
      openToWork = data['openToWork'] == 1 || data['openToWork'] == true;
      phone = data['phone'];
      
      // University information
      university = data['university'];
      degree = data['degree'];
      graduationYear = data['graduationYear'];
      gpa = data['gpa'] != null ? double.tryParse(data['gpa'].toString()) : null;
      
      // Social links
      portfolioUrl = data['portfolioUrl'];
      linkedinUrl = data['linkedinUrl'];
      githubUrl = data['githubUrl'];
      
      print('Parsing education...'); // Debug log
      education = (data['education'] as List<dynamic>? ?? []).map((e) => Education.fromJson(e)).toList();
      
      print('Parsing skills...'); // Debug log
      skills = (data['skills'] as List<dynamic>? ?? []).cast<String>();
      
      print('Parsing experience...'); // Debug log
      experience = (data['experience'] as List<dynamic>? ?? []).map((e) => Experience.fromJson(e)).toList();
      
      print('Profile fetch completed successfully'); // Debug log
    } catch (e) {
      print('Profile fetch error: $e'); // Debug log
      error = 'Failed to load profile: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
