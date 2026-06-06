class PostModel {
  final int id;
  final int userId;
  final int communityId;
  final String text;
  final DateTime postDate;
  final String mediaUrl;
  final int voteCount;
  final bool userHasVoted;

  const PostModel({
    required this.id,
    required this.userId,
    required this.communityId,
    required this.text,
    required this.postDate,
    required this.mediaUrl,
    this.voteCount = 0,
    this.userHasVoted = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        id: (json['id'] as num).toInt(),
        userId: (json['userId'] as num).toInt(),
        communityId: (json['communityId'] as num).toInt(),
        text: json['text'] as String? ?? '',
        postDate: DateTime.parse(json['postDate'] as String),
        mediaUrl: json['mediaUrl'] as String? ?? '',
        voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
        userHasVoted: json['userHasVoted'] as bool? ?? false,
      );

  bool get hasMedia => mediaUrl.isNotEmpty;

  PostModel copyWith({int? voteCount, bool? userHasVoted}) => PostModel(
        id: id,
        userId: userId,
        communityId: communityId,
        text: text,
        postDate: postDate,
        mediaUrl: mediaUrl,
        voteCount: voteCount ?? this.voteCount,
        userHasVoted: userHasVoted ?? this.userHasVoted,
      );
}
