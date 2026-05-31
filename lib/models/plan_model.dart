class PlanModel {
  final int id;
  final String name;
  final double price;
  final int maxCommunities;
  final int maxTime;

  const PlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.maxCommunities,
    required this.maxTime,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) => PlanModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        // Backend has typo 'maxComunities' — handle both spellings
        maxCommunities: (json['maxComunities'] ?? json['maxCommunities'] as num?)
                ?.toInt() ??
            0,
        maxTime: (json['maxTime'] as num?)?.toInt() ?? 0,
      );
}
