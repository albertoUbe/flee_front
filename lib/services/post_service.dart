import 'dart:typed_data';
import '../core/constants/api_constants.dart';
import '../models/post_model.dart';
import 'api_client.dart';

class PostService {
  Future<List<PostModel>> getAllPosts() async {
    final data = await ApiClient.get(ApiConstants.allPosts());
    return (data as List)
        .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PostModel>> getFeedByUser(int userId) async {
    final data = await ApiClient.get(ApiConstants.userFeed(userId));
    return (data as List)
        .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PostModel>> getPostsByCommunity(int communityId) async {
    final data = await ApiClient.get(ApiConstants.postsByCommunity(communityId));
    return (data as List)
        .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
        .toList();
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
