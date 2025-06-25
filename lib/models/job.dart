class Job {
  final int id;
  final String companyName;
  final String imgUrl;
  final String position;
  final String location;
  final String type;
  final List<String> responsibilities;
  final List<String> qualifications;
  final String postedBy;
  final String companyLogoUrl;

  Job({
    required this.id,
    required this.companyName,
    required this.imgUrl,
    required this.position,
    required this.location,
    required this.type,
    required this.responsibilities,
    required this.qualifications,
    required this.postedBy,
    required this.companyLogoUrl,
  });

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'] is int
          ? map['id']
          : int.tryParse(map['id']?.toString() ?? '') ?? 0,
      companyName: map['company'] ?? map['companyName'] ?? '',
      imgUrl: map['imgUrl'] ?? 'assets/icons/briefcase.svg', // default icon
      position: map['title'] ?? map['position'] ?? '',
      location: map['location'] ?? '',
      type: map['type'] ?? '',
      responsibilities: map['responsibilities'] is List
          ? List<String>.from(map['responsibilities'])
          : (map['description'] != null ? [map['description']] : []),
      qualifications: map['qualifications'] is List
          ? List<String>.from(map['qualifications'])
          : (map['requirements'] != null ? [map['requirements']] : []),
      postedBy: map['postedBy'] ?? '',
      companyLogoUrl: map['companyLogoUrl'] ?? '',
    );
  }
}
