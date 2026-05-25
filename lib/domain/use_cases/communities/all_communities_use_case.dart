import 'package:flee_front/domain/entities/community.dart';
import 'package:flee_front/domain/repositories/community_repository.dart';

class AllCommunitiesUseCase {
  final CommunityRepository communityRepository;
  AllCommunitiesUseCase(this.communityRepository);

  Future<List<Community>> call() => communityRepository.getAll();
}
