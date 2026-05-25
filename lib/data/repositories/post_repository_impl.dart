import 'dart:io';

import 'package:flee_front/data/services/api_service.dart';
import 'package:flee_front/domain/entities/post.dart';
import 'package:flee_front/domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final ApiService api;
  PostRepositoryImpl(this.api);

  @override
  Future<List<Post>> getAll() async {
    final list = await api.getAllPosts();
    return list.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Post>> getByCommunity(int communityId) async {
    final list = await api.getPostsByCommunity(communityId);
    return list.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Post> create({
    required int userId,
    required int communityId,
    required String text,
    File? image,
  }) async {
    final json = await api.createPost(
      userId: userId,
      communityId: communityId,
      text: text,
    );
    return Post.fromJson(json);
  }

  @override
  Future<void> vote(int postId, int userId) => api.votePost(postId, userId);

  @override
  Future<void> delete(int id) => api.deletePost(id);
}
