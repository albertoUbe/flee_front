import 'package:flee_front/domain/entities/post.dart';
import 'package:flee_front/domain/repositories/post_repository.dart';

class AllPostUseCase {
  final PostRepository postRepository;
  AllPostUseCase(this.postRepository);

  Future<List<Post>> call() => postRepository.getAll();
}
