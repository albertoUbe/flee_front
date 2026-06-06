class CommunityModel {
  final int id;
  final int creatorId;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime endDate;
  final DateTime ghostDate;
  final String communityStatus;
  final int memberCount;

  const CommunityModel({
    required this.id,
    required this.creatorId,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.endDate,
    required this.ghostDate,
    required this.communityStatus,
    this.memberCount = 0,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) => CommunityModel(
        id: (json['id'] as num).toInt(),
        creatorId: (json['creatorId'] as num).toInt(),
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        ghostDate: DateTime.parse(json['ghostDate'] as String),
        communityStatus: json['communityStatus'] as String? ?? 'Active',
        memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      );

  bool get isActive => communityStatus == 'Active';
  bool get isGhost => communityStatus == 'Ghost';
  bool get isEnded => communityStatus == 'Ended';
}
