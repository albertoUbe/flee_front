class User {
  final int id;
  final int planId;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String bio;
  final String? avatarUrl;
  final String userStatus;

  User({
    required this.id,
    required this.planId,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    required this.bio,
    this.avatarUrl,
    required this.userStatus,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as num).toInt(),
      planId: (json['planId'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      bio: json['bio'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      userStatus: json['userStatus'] as String? ?? 'NotVerified',
    );
  }

  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty)
      .take(2)
      .map((s) => s[0].toUpperCase())
      .join();

  bool get isVerified => userStatus == 'Verified' || userStatus == 'Active';
}
