class Application {
  final int studentID;
  final int internshipID;
  final String applicationDate;
  final String status;
  final String? title;
  final String? location;
  final int? companyID;
  final String? companyName;
  final double? minSalary;
  final double? maxSalary;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? aboutMe;
  final String? university;
  final String? degree;
  final String? graduationYear;
  final double? gpa;
  final List<String> skills;
  final List<Map<String, dynamic>> experience;
  final List<Map<String, dynamic>> education;
  final String? portfolioUrl;
  final String? linkedinUrl;
  final String? githubUrl;

  Application({
    required this.studentID,
    required this.internshipID,
    required this.applicationDate,
    required this.status,
    this.title,
    this.location,
    this.companyID,
    this.companyName,
    this.minSalary,
    this.maxSalary,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.aboutMe,
    this.university,
    this.degree,
    this.graduationYear,
    this.gpa,
    this.skills = const [],
    this.experience = const [],
    this.education = const [],
    this.portfolioUrl,
    this.linkedinUrl,
    this.githubUrl,
  });

  String get studentName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return 'Student #$studentID';
  }

  factory Application.fromJson(Map<String, dynamic> json) => Application(
        studentID: _parseInt(json['studentID']),
        internshipID: _parseInt(json['internshipID']),
        applicationDate: json['applicationDate']?.toString() ?? '',
        status: json['status']?.toString() ?? 'pending',
        title: json['title']?.toString(),
        location: json['location']?.toString(),
        companyID: _parseInt(json['companyID']),
        companyName: json['companyName']?.toString(),
        minSalary: _parseDouble(json['minSalary']),
        maxSalary: _parseDouble(json['maxSalary']),
        firstName: json['firstName']?.toString(),
        lastName: json['lastName']?.toString(),
        email: json['email']?.toString(),
        phone: json['phone']?.toString(),
        aboutMe: json['aboutMe']?.toString(),
        university: json['university']?.toString(),
        degree: json['degree']?.toString(),
        graduationYear: json['graduationYear']?.toString(),
        gpa: _parseDouble(json['gpa']),
        skills: _parseStringList(json['skills']),
        experience: _parseExperienceList(json['experience']),
        education: _parseEducationList(json['education']),
        portfolioUrl: json['portfolioUrl']?.toString(),
        linkedinUrl: json['linkedinUrl']?.toString(),
        githubUrl: json['githubUrl']?.toString(),
      );

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      // Handle comma-separated string
      return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  static List<Map<String, dynamic>> _parseExperienceList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static List<Map<String, dynamic>> _parseEducationList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
