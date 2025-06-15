class JobModel {
  final String id;
  final String employerId;
  final String title;
  final String company;
  final String description;
  final String category;
  final String location;
  final String salary;
  final String? agePreference;
  final String? genderPreference;
  final List<String> requirements;
  final String employmentType; // 'full_time', 'part_time', 'freelance'
  final DateTime postedAt;
  final DateTime expiresAt;
  final bool isActive;
  final String? companyLogo;

  JobModel({
    required this.id,
    required this.employerId,
    required this.title,
    required this.company,
    required this.description,
    required this.category,
    required this.location,
    required this.salary,
    this.agePreference,
    this.genderPreference,
    required this.requirements,
    required this.employmentType,
    required this.postedAt,
    required this.expiresAt,
    required this.isActive,
    this.companyLogo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employerId': employerId,
      'title': title,
      'company': company,
      'description': description,
      'category': category,
      'location': location,
      'salary': salary,
      'agePreference': agePreference,
      'genderPreference': genderPreference,
      'requirements': requirements,
      'employmentType': employmentType,
      'postedAt': postedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isActive': isActive,
      'companyLogo': companyLogo,
    };
  }

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'] ?? '',
      employerId: map['employerId'] ?? '',
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      salary: map['salary'] ?? '',
      agePreference: map['agePreference'],
      genderPreference: map['genderPreference'],
      requirements: List<String>.from(map['requirements'] ?? []),
      employmentType: map['employmentType'] ?? 'full_time',
      postedAt: DateTime.parse(map['postedAt']),
      expiresAt: DateTime.parse(map['expiresAt']),
      isActive: map['isActive'] ?? true,
      companyLogo: map['companyLogo'],
    );
  }
}
