class Application {
  final int studentID;
  final int internshipID;
  final String applicationDate;
  final String status;

  Application({
    required this.studentID,
    required this.internshipID,
    required this.applicationDate,
    required this.status,
  });

  factory Application.fromJson(Map<String, dynamic> json) => Application(
        studentID: json['studentID'],
        internshipID: json['internshipID'],
        applicationDate: json['applicationDate'],
        status: json['status'],
      );
}
