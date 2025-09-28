import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'dashboard/student_dashboard.dart';
import 'dashboard/company_dashboard.dart';
import 'internships/internships_screen.dart';
import 'applications/applications_screen.dart';
import 'applications/company_applications_screen.dart';
import 'companies/companies_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _userType = AppConstants.studentType;

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    final storedType = prefs.getString(AppConstants.userTypeKey);
    if (mounted) {
      setState(() => _userType = storedType ?? AppConstants.studentType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _userType == AppConstants.studentType ? const StudentDashboard() : const CompanyDashboard(),
      const InternshipsScreen(),
      _userType == AppConstants.studentType ? const ApplicationsScreen() : const CompanyApplicationsScreen(),
      const CompaniesScreen(),
      ProfileScreen(userType: _userType),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Internships'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Applications'),
          BottomNavigationBarItem(icon: Icon(Icons.business_outlined), label: 'Companies'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
