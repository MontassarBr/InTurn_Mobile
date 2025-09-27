import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CompanyProfileProvider with ChangeNotifier {
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
      companyName = data['companyName'];
      website = data['website'];
      industry = data['industry'];
      workDayStart = data['workDayStart'];
      workDayEnd = data['workDayEnd'];
      benefits = (data['benefits'] as List<dynamic>).cast<String>();
    } catch (e) {
      error = 'Failed to load company profile';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllCompanies() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      // Mock data for now - in real app, this would be an API call
      _allCompanies = [
        {
          'companyName': 'TechCorp Solutions',
          'industry': 'Technology',
          'website': 'https://techcorp.com',
          'description': 'Leading technology company focused on innovation and growth.',
        },
        {
          'companyName': 'HealthFirst Medical',
          'industry': 'Healthcare',
          'website': 'https://healthfirst.com',
          'description': 'Healthcare company dedicated to improving patient care.',
        },
        {
          'companyName': 'FinancePro',
          'industry': 'Finance',
          'website': 'https://financepro.com',
          'description': 'Financial services company with a focus on digital banking.',
        },
        {
          'companyName': 'EduTech Academy',
          'industry': 'Education',
          'website': 'https://edutech.com',
          'description': 'Educational technology company revolutionizing learning.',
        },
        {
          'companyName': 'GreenEnergy Corp',
          'industry': 'Technology',
          'website': 'https://greenenergy.com',
          'description': 'Sustainable energy solutions for a better future.',
        },
      ];
    } catch (e) {
      error = 'Failed to load companies';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
