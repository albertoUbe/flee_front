import 'package:flee_front/domain/entities/post.dart';
import 'package:flee_front/domain/repositories/post_repository.dart';

class PostByCommunityUseCase {
  final PostRepository postRepository;
  PostByCommunityUseCase(this.postRepository);

  Future<List<Post>> call({required int communityId}) =>
      postRepository.getByCommunity(communityId);
}
