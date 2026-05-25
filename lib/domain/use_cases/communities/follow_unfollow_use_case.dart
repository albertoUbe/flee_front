import 'package:flee_front/domain/repositories/community_repository.dart';

class FollowUnfollowUseCase {
  final CommunityRepository communityRepository;
  FollowUnfollowUseCase(this.communityRepository);

  Future<void> call({required int userId, required int communityId}) =>
      communityRepository.followUnfollow(userId, communityId);
}
