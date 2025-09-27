import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/profile/student_profile.dart';
import '../../widgets/profile/company_profile.dart';

class ProfileScreen extends StatelessWidget {
  final String userType;
  const ProfileScreen({Key? key, required this.userType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return userType == AppConstants.studentType ? const StudentProfile() : const CompanyProfile();
  }
}
