import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Center(
        child: Text(
          'Welcome, Student!',
          style: AppConstants.headingStyle,
        ),
      ),
    );
  }
}