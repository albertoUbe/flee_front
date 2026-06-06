import 'dart:typed_data';
import '../core/constants/api_constants.dart';
import '../models/post_model.dart';
import 'api_client.dart';

class PostPage {
  final List<PostModel> items;
  final bool hasMore;
  PostPage({required this.items, required this.hasMore});
}

class PostService {
  Future<List<PostModel>> getAllPosts() async {
    final data = await ApiClient.get(ApiConstants.allPosts());
    return (data as List)
        .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PostPage> getFeedByUser(int userId, {int page = 1}) async {
    final data = await ApiClient.get(ApiConstants.userFeed(userId, page: page));
    final map = data as Map<String, dynamic>;
    return PostPage(
      items: (map['items'] as List)
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: map['hasMore'] as bool,
    );
  }

  Future<List<PostModel>> getTopPosts() async {
    final data = await ApiClient.get(ApiConstants.topPosts());
    return (data as List)
        .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PostPage> getPostsByCommunity(int communityId, {int page = 1}) async {
    final data = await ApiClient.get(
        ApiConstants.postsByCommunity(communityId, page: page));
    final map = data as Map<String, dynamic>;
    return PostPage(
      items: (map['items'] as List)
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: map['hasMore'] as bool,
    );
  }

  Future<PostModel> createPost(
    int userId,
    int communityId,
    String text, {
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final fields = {
      'userId': userId.toString(),
      'communityId': communityId.toString(),
      'text': text,
    };

    final data = await ApiClient.postMultipart(
      ApiConstants.createPost(),
      fields,
      fileBytes: imageBytes,
      fileName: imageName,
      fileField: imageBytes != null ? 'file' : null,
    );
    return PostModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> vote(int postId, int userId) async {
    await ApiClient.post(ApiConstants.votePost(postId, userId), {});
  }

  Future<void> deletePost(int id) async {
    await ApiClient.delete(ApiConstants.deletePost(id));
  }
}
