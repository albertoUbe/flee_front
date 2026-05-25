import 'package:flee_front/domain/entities/community.dart';

abstract class CommunityRepository {
  // GET /api/community
  Future<List<Community>> getAll();
  // GET /api/community/user/{userId}
  Future<List<Community>> getByUser(int userId);
  // POST /api/community/
  Future<Community> create({
    required int creatorId,
    required String name,
    required String description,
    required int duration,
  });
  // POST /api/community/{userId}/follow/{communityId}
  Future<void> followUnfollow(int userId, int communityId);
  // POST /api/community/{userId}/{ownerId}/admin/{communityId}
  Future<void> manageAdmin(int userId, int ownerId, int communityId);
}
