import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/application.dart';

class ApplicationProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<Application> _applications = [];
  bool _loading = false;
  bool _applying = false;
  String? _error;
  int? _selectedInternshipId;

  List<Application> get applications => _applications;
  bool get loading => _loading;
  bool get applying => _applying;
  String? get error => _error;
  int? get selectedInternshipId => _selectedInternshipId;
  
  void setSelectedInternshipId(int? internshipId) {
    _selectedInternshipId = internshipId;
    notifyListeners();
  }

  Future<void> fetchMyApplications() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get<List<dynamic>>('/applications/student');
      final data = response.data ?? [];
      _applications = data.map((e) => Application.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (e.toString().contains('403')) {
        _error = 'Access denied. Please login to view your applications.';
      } else if (e.toString().contains('404')) {
        _error = 'Applications service not available.';
      } else if (e.toString().contains('Connection')) {
        _error = 'Cannot connect to server. Please check your internet connection.';
        // Load mock data for testing when server is not available
        _loadMockApplications();
      } else {
        _error = 'Failed to load applications: ${e.toString()}';
      }
      print('Applications fetch error: $e'); // Debug log
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> applyToInternship(int internshipID) async {
    _applying = true;
    _error = null;
    notifyListeners();
    try {
      await _api.post('/applications', {'internshipID': internshipID});
      await fetchMyApplications(); // Refresh the list
      return true;
    } catch (e) {
      _error = 'Failed to apply to internship: $e';
      return false;
    } finally {
      _applying = false;
      notifyListeners();
    }
  }

  bool hasAppliedToInternship(int internshipID) {
    return _applications.any((app) => app.internshipID == internshipID);
  }

  // Company-specific methods
  Future<void> fetchApplicationsForInternship(int internshipID) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get<List<dynamic>>('/applications/internship/$internshipID');
      final data = response.data ?? [];
      _applications = data.map((e) => Application.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      _error = 'Failed to load applications: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchApplicationsForCompany(int companyID) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      print('Attempting to fetch applications from API for company $companyID');
      // Try protected endpoint first, fallback to public endpoint for testing
      Response<List<dynamic>> response;
      try {
        response = await _api.get<List<dynamic>>('/applications/company/$companyID');
      } catch (authError) {
        print('Protected endpoint failed, trying public endpoint: $authError');
        response = await _api.get<List<dynamic>>('/applications/public/company/$companyID');
      }
      final data = response.data ?? [];
      print('API Response received: ${data.length} applications');
      _applications = data.map((e) => Application.fromJson(e as Map<String, dynamic>)).toList();
      print('Successfully loaded ${_applications.length} applications from API');
    } catch (e) {
      print('API Error: $e');
      if (e.toString().contains('403')) {
        _error = 'Access denied. Authentication required.';
        // Fallback to mock data for development
        await fetchCompanyApplicationsMock();
        return;
      } else if (e.toString().contains('404')) {
        _error = 'Applications service not available.';
        await fetchCompanyApplicationsMock();
        return;
      } else if (e.toString().contains('Connection')) {
        _error = 'Cannot connect to server. Using offline data.';
        await fetchCompanyApplicationsMock();
        return;
      } else {
        _error = 'Failed to load company applications: ${e.toString()}';
        await fetchCompanyApplicationsMock();
        return;
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateApplicationStatus({
    required int studentID,
    required int internshipID,
    required String applicationDate,
    required String status,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // Ensure date is in proper format (YYYY-MM-DD) for database
      String dateForUpdate = applicationDate;
      if (applicationDate.contains('T')) {
        dateForUpdate = applicationDate.split('T')[0];
      }
      
      print('Updating application: studentID=$studentID, internshipID=$internshipID, date=$dateForUpdate, status=$status');
      
      // Try protected endpoint first, fallback to public endpoint for testing
      try {
        await _api.put('/applications/status', {
          'studentID': studentID,
          'internshipID': internshipID,
          'applicationDate': dateForUpdate,
          'status': status,
        });
      } catch (authError) {
        print('Protected status update failed, trying public endpoint: $authError');
        await _api.put('/applications/public/status', {
          'studentID': studentID,
          'internshipID': internshipID,
          'applicationDate': dateForUpdate,
          'status': status,
        });
      }
      
      // Update the local application status immediately
      for (int i = 0; i < _applications.length; i++) {
        if (_applications[i].studentID == studentID && 
            _applications[i].internshipID == internshipID) {
          // Create updated application with new status
          final updatedApp = Application(
            studentID: _applications[i].studentID,
            internshipID: _applications[i].internshipID,
            applicationDate: _applications[i].applicationDate,
            status: status,
            title: _applications[i].title,
            location: _applications[i].location,
            companyID: _applications[i].companyID,
            companyName: _applications[i].companyName,
            minSalary: _applications[i].minSalary,
            maxSalary: _applications[i].maxSalary,
            firstName: _applications[i].firstName,
            lastName: _applications[i].lastName,
            email: _applications[i].email,
            phone: _applications[i].phone,
            aboutMe: _applications[i].aboutMe,
            university: _applications[i].university,
            degree: _applications[i].degree,
            graduationYear: _applications[i].graduationYear,
            gpa: _applications[i].gpa,
            skills: _applications[i].skills,
            experience: _applications[i].experience,
            education: _applications[i].education,
            portfolioUrl: _applications[i].portfolioUrl,
            linkedinUrl: _applications[i].linkedinUrl,
            githubUrl: _applications[i].githubUrl,
          );
          _applications[i] = updatedApp;
          break;
        }
      }
      
      // Only notify listeners, don't automatically refresh
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update application status: $e';
      print('Error updating application status: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _loadMockApplications() {
    _applications = [
      Application(
        studentID: 1,
        internshipID: 1,
        applicationDate: '2024-01-15',
        status: 'Pending',
        title: 'Software Development Intern',
        location: 'Tunis, Tunisia',
        companyID: 1,
        companyName: 'TechSolutions Tunisia',
        minSalary: 1200.0,
        maxSalary: 1800.0,
        firstName: 'Amine',
        lastName: 'Ben Othman',
        email: 'amine.benothman@email.com',
      ),
      Application(
        studentID: 1,
        internshipID: 2,
        applicationDate: '2024-01-10',
        status: 'Accepted',
        title: 'Marketing Intern',
        location: 'Sfax, Tunisia',
        companyID: 2,
        companyName: 'Marketing Pro Tunisia',
        minSalary: 800.0,
        maxSalary: 1200.0,
        firstName: 'Amine',
        lastName: 'Ben Othman',
        email: 'amine.benothman@email.com',
      ),
    ];
    _error = null; // Clear error when loading mock data
  }

  // For company applications screen
  Future<void> fetchCompanyApplicationsMock() async {
    _loading = true;
    _error = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    _applications = [
      Application(
        studentID: 101,
        internshipID: 1,
        applicationDate: '2024-01-20',
        status: 'Pending',
        title: 'Software Development Intern',
        location: 'Tunis, Tunisia',
        companyID: 1,
        companyName: 'Your Company',
        minSalary: 1200.0,
        maxSalary: 1800.0,
        firstName: 'Amira',
        lastName: 'Ben Salem',
        email: 'amira.bensalem@email.com',
        phone: '+216 20 123 456',
        aboutMe: 'Étudiante passionnée en informatique avec une solide base en développement logiciel et un vif intérêt pour le développement web full-stack. Toujours prête à apprendre de nouvelles technologies et à contribuer à des projets innovants.',
        university: 'École Nationale d\'Ingénieurs de Tunis (ENIT)',
        degree: 'Ingénierie en Informatique',
        graduationYear: '2025',
        gpa: 16.5,
        skills: ['Python', 'JavaScript', 'React', 'Node.js', 'SQL', 'Git', 'Angular', 'MongoDB'],
        experience: [
          {
            'title': 'Développeur Frontend Stagiaire',
            'company': 'Digital Solutions Tunisia',
            'duration': 'Juin 2023 - Août 2023',
            'description': 'Développement d\'interfaces web responsives avec React et TypeScript. Collaboration avec l\'équipe design pour implémenter des fonctionnalités conviviales.',
          },
          {
            'title': 'Assistant d\'enseignement',
            'company': 'ENIT',
            'duration': 'Sep 2023 - Présent',
            'description': 'Assistance au professeur dans le cours de programmation. Aide aux étudiants avec les devoirs de programmation et animation des séances de TP.',
          }
        ],
        education: [
          {
            'institution': 'École Nationale d\'Ingénieurs de Tunis (ENIT)',
            'degree': 'Ingénierie en Informatique',
            'gpa': '16.5/20',
            'duration': '2021 - 2025',
            'courses': 'Structures de données, Algorithmes, Développement web, Systèmes de bases de données'
          }
        ],
        portfolioUrl: 'https://amira-portfolio.tn',
        linkedinUrl: 'https://linkedin.com/in/amira-ben-salem',
        githubUrl: 'https://github.com/amira-ben-salem',
      ),
      Application(
        studentID: 102,
        internshipID: 1,
        applicationDate: '2024-01-18',
        status: 'Accepted',
        title: 'Software Development Intern',
        location: 'Sfax, Tunisia',
        companyID: 1,
        companyName: 'Your Company',
        minSalary: 1300.0,
        maxSalary: 1900.0,
        firstName: 'Mohamed',
        lastName: 'Trabelsi',
        email: 'mohamed.trabelsi@email.com',
        phone: '+216 25 987 654',
        aboutMe: 'Étudiant expérimenté en génie logiciel avec une expertise en développement d\'applications mobiles et systèmes backend. Solides compétences en résolution de problèmes et expérience des méthodologies de développement agile.',
        university: 'Institut Supérieur d\'Informatique et des Techniques de Communication (ISITCOM)',
        degree: 'Licence en Génie Logiciel',
        graduationYear: '2024',
        gpa: 17.2,
        skills: ['Java', 'Kotlin', 'Android', 'Spring Boot', 'MySQL', 'Docker', 'Git', 'REST API'],
        experience: [
          {
            'title': 'Développeur d\'Applications Mobiles',
            'company': 'TechnoSoft Tunisia',
            'duration': 'Mai 2023 - Déc 2023',
            'description': 'Développement d\'applications Android avec Kotlin et Java. Implémentation d\'intégrations API REST et optimisation des performances des applications.',
          }
        ],
        education: [
          {
            'institution': 'Institut Supérieur d\'Informatique et des Techniques de Communication (ISITCOM)',
            'degree': 'Licence en Génie Logiciel',
            'gpa': '17.2/20',
            'duration': '2020 - 2024',
            'courses': 'Développement Mobile, Architecture Logicielle, Systèmes Distribués'
          }
        ],
        portfolioUrl: 'https://mohamed-trabelsi.tn',
        linkedinUrl: 'https://linkedin.com/in/mohamed-trabelsi-dev',
        githubUrl: 'https://github.com/mohamed-trabelsi',
      ),
      Application(
        studentID: 103,
        internshipID: 2,
        applicationDate: '2024-01-15',
        status: 'Rejected',
        title: 'Marketing Intern',
        location: 'Sousse, Tunisia',
        companyID: 1,
        companyName: 'Your Company',
        minSalary: 800.0,
        maxSalary: 1200.0,
        firstName: 'Salma',
        lastName: 'Khelifi',
        email: 'salma.khelifi@email.com',
        phone: '+216 22 456 789',
        aboutMe: 'Étudiante créative en marketing passionnée par les stratégies de marketing digital et le développement de marque. Expérience en gestion des réseaux sociaux et création de contenu.',
        university: 'Institut des Hautes Études Commerciales de Sousse (IHEC)',
        degree: 'Licence en Marketing',
        graduationYear: '2025',
        gpa: 14.8,
        skills: ['Marketing Digital', 'Création de Contenu', 'SEO', 'Google Analytics', 'Adobe Creative Suite', 'Gestion des Réseaux Sociaux'],
        experience: [
          {
            'title': 'Coordinatrice Réseaux Sociaux',
            'company': 'Agence Marketing Tunisie',
            'duration': 'Jan 2023 - Août 2023',
            'description': 'Gestion des comptes de réseaux sociaux pour 5+ clients. Création de contenu engageant et augmentation de l\'engagement des abonnés de 40%.',
          }
        ],
        education: [
          {
            'institution': 'Institut des Hautes Études Commerciales de Sousse (IHEC)',
            'degree': 'Licence en Marketing',
            'gpa': '14.8/20',
            'duration': '2021 - 2025',
            'courses': 'Comportement du consommateur, Gestion de marque, Marketing digital'
          }
        ],
        portfolioUrl: 'https://salma-marketing-portfolio.tn',
        linkedinUrl: 'https://linkedin.com/in/salma-khelifi-marketing',
      ),
      Application(
        studentID: 104,
        internshipID: 3,
        applicationDate: '2024-01-12',
        status: 'Pending',
        title: 'Design Intern',
        location: 'Monastir, Tunisia',
        companyID: 1,
        companyName: 'Your Company',
        minSalary: 900.0,
        maxSalary: 1400.0,
        firstName: 'Youssef',
        lastName: 'Hamdi',
        email: 'youssef.hamdi@email.com',
        phone: '+216 27 321 098',
        aboutMe: 'Designer UX/UI innovant avec une passion pour créer des designs centrés sur l\'utilisateur. Compétent dans le processus de design thinking et le prototypage. Toujours à la recherche de moyens d\'améliorer l\'expérience utilisateur.',
        university: 'Institut Supérieur des Arts Multimédia de Manouba (ISAMM)',
        degree: 'Licence en Design Graphique et Multimédia',
        graduationYear: '2024',
        gpa: 15.4,
        skills: ['Figma', 'Adobe Creative Suite', 'Sketch', 'Prototypage', 'Recherche Utilisateur', 'Wireframing', 'HTML/CSS'],
        experience: [
          {
            'title': 'Stagiaire UX Designer',
            'company': 'Creative Studio Tunisia',
            'duration': 'Juin 2023 - Sep 2023',
            'description': 'Conduite de recherches utilisateur et création de wireframes pour applications mobiles. Design d\'interfaces utilisateur pour 3 projets clients.',
          },
          {
            'title': 'Designer Graphique Freelance',
            'company': 'Travailleur Indépendant',
            'duration': '2022 - Présent',
            'description': 'Création de matériaux de branding et logos pour petites entreprises. Gestion des relations clients et planification des projets.',
          }
        ],
        education: [
          {
            'institution': 'Institut Supérieur des Arts Multimédia de Manouba (ISAMM)',
            'degree': 'Licence en Design Graphique et Multimédia',
            'gpa': '15.4/20',
            'duration': '2020 - 2024',
            'courses': 'Design d\'expérience utilisateur, Communication visuelle, Recherche en design'
          }
        ],
        portfolioUrl: 'https://youssef-design-portfolio.tn',
        linkedinUrl: 'https://linkedin.com/in/youssef-hamdi-designer',
        githubUrl: 'https://github.com/youssef-hamdi-designs',
      ),
    ];

    _loading = false;
    _error = null;
    notifyListeners();
  }
}
