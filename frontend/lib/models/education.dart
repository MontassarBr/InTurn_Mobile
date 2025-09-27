class Education {
  final String institution;
  final String diploma;
  final String? location;
  final String startDate;
  final String? endDate;

  Education({
    required this.institution,
    required this.diploma,
    this.location,
    required this.startDate,
    this.endDate,
  });

  factory Education.fromJson(Map<String, dynamic> json) => Education(
        institution: json['institution'],
        diploma: json['diploma'],
        location: json['location'],
        startDate: json['startDate'],
        endDate: json['endDate'],
      );
}
