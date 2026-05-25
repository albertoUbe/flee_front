import 'package:flee_front/domain/repositories/post_repository.dart';

class VotePostUseCase {
  final PostRepository postRepository;
  VotePostUseCase(this.postRepository);

  Future<void> call({required int postId, required int userId}) =>
      postRepository.vote(postId, userId);
}
