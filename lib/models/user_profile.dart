class UserProfile {
  final String phone;
  final String role;
  final String name;
  final String email;
  final String? profileImagePath;
  final DateTime? memberSince;

  UserProfile({
    required this.phone,
    this.role = 'CUSTOMER',
    this.name = '',
    this.email = '',
    this.profileImagePath,
    this.memberSince,
  });

  UserProfile copyWith({
    String? phone,
    String? role,
    String? name,
    String? email,
    String? profileImagePath,
    DateTime? memberSince,
  }) {
    return UserProfile(
      phone: phone ?? this.phone,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      memberSince: memberSince ?? this.memberSince,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'role': role,
      'name': name,
      'email': email,
      'profileImagePath': profileImagePath,
      'memberSince': memberSince?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<dynamic, dynamic> json) {
    return UserProfile(
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'CUSTOMER',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImagePath: json['profileImagePath'],
      memberSince: DateTime.tryParse(json['memberSince'] ?? ''),
    );
  }
}
