import 'package:flee_front/data/services/api_service.dart';
import 'package:flee_front/domain/entities/community.dart';
import 'package:flee_front/domain/repositories/community_repository.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final ApiService api;
  CommunityRepositoryImpl(this.api);

  @override
  Future<List<Community>> getAll() async {
    final list = await api.getAllCommunities();
    return list
        .map((e) => Community.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Community>> getByUser(int userId) async {
    final list = await api.getCommunitiesByUser(userId);
    return list
        .map((e) => Community.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Community> create({
    required int creatorId,
    required String name,
    required String description,
    required int duration,
  }) async {
    final json = await api.createCommunity(
      creatorId: creatorId,
      name: name,
      description: description,
      duration: duration,
    );
    return Community.fromJson(json);
  }

  @override
  Future<void> followUnfollow(int userId, int communityId) async {
    api.followUnfollow(userId, communityId);
  }

  @override
  Future<void> manageAdmin(int userId, int ownerId, int communityId) =>
      api.manageAdmin(userId, ownerId, communityId);
}
