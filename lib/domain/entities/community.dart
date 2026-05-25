class Community {
  final int id;
  final int creatorId;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime endDate;
  final DateTime ghostDate;
  final String communityStatus;

  Community({
    required this.id,
    required this.creatorId,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.endDate,
    required this.ghostDate,
    required this.communityStatus,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: (json['id'] as num).toInt(),
      creatorId: (json['creatorId'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      ghostDate: DateTime.parse(json['ghostDate'] as String),
      communityStatus: json['communityStatus'] as String? ?? 'Active',
    );
  }

  String get timeToLeft {
    final expire = endDate.difference(DateTime.now());
    if (expire.isNegative) {
      return 'The community was fleeting, its time has passed.';
    }
    if (expire.inDays > 0) return '${expire.inDays}d left';
    if (expire.inHours > 0) return '${expire.inHours}h left';
    return '${expire.inMinutes}m left';
  }
}
