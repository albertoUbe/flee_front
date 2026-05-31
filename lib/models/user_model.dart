import 'dart:convert';

class UserModel {
  final int id;
  final int planId;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String bio;
  final String avatarUrl;
  final String userStatus;

  const UserModel({
    required this.id,
    required this.planId,
    required this.name,
    required this.email,
    required this.createdAt,
    this.updatedAt,
    required this.bio,
    required this.avatarUrl,
    required this.userStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['id'] as num).toInt(),
        planId: (json['planId'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
        bio: json['bio'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String? ?? '',
        userStatus: json['userStatus'] as String? ?? 'Active',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'planId': planId,
        'name': name,
        'email': email,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'bio': bio,
        'avatarUrl': avatarUrl,
        'userStatus': userStatus,
      };

  String toJsonString() => jsonEncode(toJson());

  static UserModel fromJsonString(String jsonStr) =>
      UserModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);

  UserModel copyWith({
    String? name,
    String? bio,
    String? avatarUrl,
    String? userStatus,
    int? planId,
  }) =>
      UserModel(
        id: id,
        planId: planId ?? this.planId,
        name: name ?? this.name,
        email: email,
        createdAt: createdAt,
        updatedAt: updatedAt,
        bio: bio ?? this.bio,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        userStatus: userStatus ?? this.userStatus,
      );
}
