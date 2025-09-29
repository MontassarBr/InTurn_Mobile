import 'internship.dart';

class SavedInternship {
  final int studentID;
  final int internshipID;
  final String savedDate;
  final Internship? internship; // Joined internship data

  SavedInternship({
    required this.studentID,
    required this.internshipID,
    required this.savedDate,
    this.internship,
  });

  factory SavedInternship.fromJson(Map<String, dynamic> json) => SavedInternship(
        studentID: _parseInt(json['studentID']),
        internshipID: _parseInt(json['internshipID']),
        savedDate: json['savedDate']?.toString() ?? '',
        internship: json['internship'] != null 
            ? Internship.fromJson(json['internship']) 
            : null,
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
}
