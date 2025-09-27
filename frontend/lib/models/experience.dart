class Experience {
  final int experienceID;
  final String title;
  final String startDate;
  final String endDate;
  final String employmentType;
  final String companyName;
  final String? description;

  Experience({
    required this.experienceID,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.employmentType,
    required this.companyName,
    this.description,
  });

  factory Experience.fromJson(Map<String, dynamic> json) => Experience(
        experienceID: json['experienceID'],
        title: json['title'],
        startDate: json['startDate'],
        endDate: json['endDate'],
        employmentType: json['employmentType'],
        companyName: json['companyName'],
        description: json['description'],
      );
}
