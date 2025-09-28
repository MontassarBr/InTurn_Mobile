import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CompanyProfileProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  String companyName = '';
  String? website;
  String? industry;
  String? workDayStart;
  String? workDayEnd;
  List<String> benefits = [];
  List<Map<String, dynamic>> _allCompanies = [];

  bool loading = false;
  String? error;

  List<Map<String, dynamic>> get allCompanies => _allCompanies;

  Future<void> addBenefit(String benefit) async {
    loading = true;
    notifyListeners();
    try {
      await _api.post('/companies/benefits', {'benefit': benefit});
      await fetchProfile();
    } catch (_) {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBenefit(String benefit) async {
    loading = true;
    notifyListeners();
    try {
      await _api.delete('/companies/benefits/$benefit');
      await fetchProfile();
    } catch (_) {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _api.put('/companies/me', data);
      await fetchProfile();
      return true;
    } catch (e) {
      error = 'Failed to update profile';
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
      final response = await _api.get<Map<String, dynamic>>('/companies/full');
      final data = response.data!;
      companyName = data['companyName'] ?? 'Your Company';
      website = data['website'];
      industry = data['industry'];
      workDayStart = data['workDayStart'];
      workDayEnd = data['workDayEnd'];
      benefits = (data['benefits'] as List<dynamic>?)?.cast<String>() ?? [];
    } catch (e) {
      print('Failed to load company profile: $e');
      // Load mock data as fallback
      _loadMockProfile();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _loadMockProfile() {
    companyName = 'Your Company';
    website = 'https://yourcompany.com';
    industry = 'Technology';
    workDayStart = '09:00';
    workDayEnd = '17:00';
    benefits = ['Health Insurance', 'Flexible Hours', 'Remote Work', 'Professional Development'];
    error = null;
  }

  Future<void> fetchAllCompanies() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      print('Fetching all companies from API...');
      final response = await _api.get<List<dynamic>>('/companies/all');
      
      _allCompanies = response.data!.map<Map<String, dynamic>>((company) {
        return {
          'companyID': company['companyID'],
          'companyName': company['companyName'] ?? 'Unknown Company',
          'industry': company['industry'] ?? 'Not specified',
          'website': company['website'],
          'description': company['description'] ?? 'No description available',
          'location': company['location'] ?? 'Location not specified',
        };
      }).toList();
      
      print('Successfully loaded ${_allCompanies.length} companies');
    } catch (e) {
      print('Error loading companies: $e');
      error = 'Failed to load companies: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
