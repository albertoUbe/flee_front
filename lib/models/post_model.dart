class PostModel {
  final int id;
  final int userId;
  final int communityId;
  final String text;
  final DateTime postDate;
  final String mediaUrl;

  const PostModel({
    required this.id,
    required this.userId,
    required this.communityId,
    required this.text,
    required this.postDate,
    required this.mediaUrl,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        id: (json['id'] as num).toInt(),
        userId: (json['userId'] as num).toInt(),
        communityId: (json['communityId'] as num).toInt(),
        text: json['text'] as String? ?? '',
        postDate: DateTime.parse(json['postDate'] as String),
        mediaUrl: json['mediaUrl'] as String? ?? '',
      );

  bool get hasMedia => mediaUrl.isNotEmpty;
}
