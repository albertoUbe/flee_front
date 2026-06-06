import '../core/constants/api_constants.dart';
import '../models/community_model.dart';
import 'api_client.dart';

class CommunityService {
  Future<List<CommunityModel>> getAllCommunities() async {
    final data = await ApiClient.get(ApiConstants.allCommunities());
    return (data as List)
        .map((e) => CommunityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CommunityModel>> getTopCommunities() async {
    final data = await ApiClient.get(ApiConstants.topCommunities());
    return (data as List)
        .map((e) => CommunityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CommunityModel>> getCommunitiesByUser(int userId) async {
    final data = await ApiClient.get(ApiConstants.communitiesByUser(userId));
    return (data as List)
        .map((e) => CommunityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CommunityModel> createCommunity(
    int creatorId,
    String name,
    String description,
    int durationWeeks,
  ) async {
    final data = await ApiClient.post(
      ApiConstants.createCommunity(),
      {
        'creatorId': creatorId,
        'name': name,
        'description': description,
        'duration': durationWeeks,
      },
    );
    return CommunityModel.fromJson(data as Map<String, dynamic>);
  }

  Future<CommunityModel> editCommunity(
    int id,
    String name,
    String description,
  ) async {
    final data = await ApiClient.put(
      ApiConstants.editCommunity(id),
      {'name': name, 'description': description},
    );
    return CommunityModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteCommunity(int id) async {
    await ApiClient.delete(ApiConstants.deleteCommunity(id));
  }

  Future<void> followUnfollow(int communityId, int userId) async {
    await ApiClient.post(ApiConstants.followCommunity(communityId, userId), {});
  }

  Future<List<CommunityModel>> searchCommunities(String name) async {
    final data = await ApiClient.get(ApiConstants.searchCommunities(name));
    return (data as List)
        .map((e) => CommunityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> manageAdmin(int communityId, int ownerId, int userId) async {
    await ApiClient.post(
      ApiConstants.manageAdmin(communityId, ownerId, userId),
      {},
    );
  }
}
