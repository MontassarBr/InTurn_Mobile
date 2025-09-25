import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class CompanyDashboard extends StatelessWidget {
  const CompanyDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Dashboard'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Center(
        child: Text(
          'Welcome, Company!',
          style: AppConstants.headingStyle,
        ),
      ),
    );
  }
}