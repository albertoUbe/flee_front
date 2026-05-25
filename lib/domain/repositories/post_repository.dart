import 'dart:io';
import 'package:flee_front/domain/entities/post.dart';

abstract class PostRepository {
  // GET /api/post
  Future<List<Post>> getAll();
  // GET /api/post/community/{communityId}
  Future<List<Post>> getByCommunity(int communityId);
  // POST /api/post
  Future<Post> create({
    required int userId,
    required int communityId,
    required String text,
    File? image,
  });
  // POST /api/post/{postId}/vote/{userId}
  Future<void> vote(int postId, int userId);
  // DELETE /api/post/{id}
  Future<void> delete(int id);
}
