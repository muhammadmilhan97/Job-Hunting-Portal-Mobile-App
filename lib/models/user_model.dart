class UserModel {
  final String uid;
  final String email;
  final String name;
  final String userType;
  final Map<String, dynamic> profileData;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.userType,
    required this.profileData,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'userType': userType,
      'profileData': profileData,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final rawProfileData = map['profileData'];

    // Defensive check: ensure it's actually a Map
    final profileData = rawProfileData is Map<String, dynamic>
        ? rawProfileData
        : (rawProfileData is Map
            ? Map<String, dynamic>.from(rawProfileData)
            : <String, dynamic>{}); // fallback if null or invalid

    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      userType: map['userType'] ?? '',
      profileData: profileData,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  // Job Seeker specific getters
  String? get cnic => profileData['cnic'];
  String? get city => profileData['city'];
  String? get country => profileData['country'];
  String? get address => profileData['address'];
  String? get experience => profileData['experience'];
  String? get expectedSalary {
    final val = profileData['expectedSalary'];
    if (val == null) return null;
    return val.toString();
  }

  // Employer specific getters
  String? get companyName => profileData['companyName'];
  String? get companyAddress => profileData['companyAddress'];
  String? get contactNumber => profileData['contactNumber'];

  String? get profileImageUrl => profileData['profile_image_url'];
  String? get phone => profileData['phone'];
  String? get education => profileData['education'];
  String? get bio => profileData['bio'];
  List<String> get skills {
    final raw = profileData['skills'];
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return [];
  }

  int? get experienceInt {
    final val = profileData['experience'];
    if (val is int) return val;
    if (val is String) return int.tryParse(val);
    return null;
  }

  int? get expectedSalaryInt {
    final val = profileData['expectedSalary'];
    if (val is int) return val;
    if (val is String) return int.tryParse(val);
    return null;
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? userType,
    Map<String, dynamic>? profileData,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      userType: userType ?? this.userType,
      profileData: profileData ?? this.profileData,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
