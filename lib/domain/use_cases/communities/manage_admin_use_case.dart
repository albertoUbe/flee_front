import 'package:flee_front/domain/repositories/community_repository.dart';

class ManageAdminUseCase {
  final CommunityRepository communityRepository;
  ManageAdminUseCase(this.communityRepository);

  Future<void> call({
    required int userId,
    required int ownerId,
    required int communityId,
  }) => communityRepository.manageAdmin(userId, ownerId, communityId);
}
