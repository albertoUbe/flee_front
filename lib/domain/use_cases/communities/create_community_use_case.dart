import 'package:flee_front/domain/entities/community.dart';
import 'package:flee_front/domain/repositories/community_repository.dart';

class CreateCommunityUseCase {
  final CommunityRepository communityRepository;
  CreateCommunityUseCase(this.communityRepository);

  Future<Community> call({
    required int creatorId,
    required String name,
    required String description,
    required int duration,
  }) => communityRepository.create(
    creatorId: creatorId,
    name: name,
    description: description,
    duration: duration,
  );
}
