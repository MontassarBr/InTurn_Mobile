import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard/company_dashboard.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard/student_dashboard.dart';
import 'theme/app_theme.dart';
import 'providers/internship_provider.dart';
import 'providers/application_provider.dart';
import 'providers/company_profile_provider.dart';
import 'providers/student_profile_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/saved_internship_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => InternshipProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
        ChangeNotifierProvider(create: (_) => CompanyProfileProvider()),
        ChangeNotifierProvider(create: (_) => StudentProfileProvider()),
        ChangeNotifierProvider(create: (_) => SavedInternshipProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'InTurn',
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
        },
      ),
      
    );
  }
}
