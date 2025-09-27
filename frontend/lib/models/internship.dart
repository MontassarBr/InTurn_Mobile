class Internship {
  final int internshipID;
  final int companyID;
  final String title;
  final String location;
  final String startDate;
  final String endDate;
  final double? minSalary;
  final double? maxSalary;
  final String? description;
  final String? payment;
  final String? workArrangement;
  final String? workTime;
  final String status;

  Internship({
    required this.internshipID,
    required this.companyID,
    required this.title,
    required this.location,
    required this.startDate,
    required this.endDate,
    this.minSalary,
    this.maxSalary,
    this.description,
    this.payment,
    this.workArrangement,
    this.workTime,
    required this.status,
  });

  factory Internship.fromJson(Map<String, dynamic> json) => Internship(
        internshipID: json['internshipID'],
        companyID: json['companyID'],
        title: json['title'],
        location: json['location'],
        startDate: json['startDate'],
        endDate: json['endDate'],
        minSalary: (json['minSalary'] as num?)?.toDouble(),
        maxSalary: (json['maxSalary'] as num?)?.toDouble(),
        description: json['description'],
        payment: json['payment'],
        workArrangement: json['workArrangement'],
        workTime: json['workTime'],
        status: json['status'],
      );
}
