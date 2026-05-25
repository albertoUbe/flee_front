import 'package:flee_front/domain/repositories/post_repository.dart';

class DeletePostUseCase {
  final PostRepository postRepository;
  DeletePostUseCase(this.postRepository);

  Future<void> call({required int id}) => postRepository.delete(id);
}
