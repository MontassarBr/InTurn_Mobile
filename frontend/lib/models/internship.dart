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
  final String? companyName;
  final String? industry;

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
    this.companyName,
    this.industry,
  });

  factory Internship.fromJson(Map<String, dynamic> json) => Internship(
        internshipID: _parseInt(json['internshipID']),
        companyID: _parseInt(json['companyID']),
        title: json['title']?.toString() ?? '',
        location: json['location']?.toString() ?? '',
        startDate: json['startDate']?.toString() ?? '',
        endDate: json['endDate']?.toString() ?? '',
        minSalary: _parseDouble(json['minSalary']),
        maxSalary: _parseDouble(json['maxSalary']),
        description: json['description']?.toString(),
        payment: json['payment']?.toString(),
        workArrangement: json['workArrangement']?.toString(),
        workTime: json['workTime']?.toString(),
        status: json['status']?.toString() ?? 'draft',
        companyName: json['companyName']?.toString(),
        industry: json['industry']?.toString(),
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
}
