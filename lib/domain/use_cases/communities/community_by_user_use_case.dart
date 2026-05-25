import 'package:flee_front/domain/entities/community.dart';
import 'package:flee_front/domain/repositories/community_repository.dart';

class CommunityByUserUseCase {
  final CommunityRepository communityRepository;
  CommunityByUserUseCase(this.communityRepository);

  Future<List<Community>> call(int userId) =>
      communityRepository.getByUser(userId);
}
