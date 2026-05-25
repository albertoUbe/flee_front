import 'dart:io';

import 'package:flee_front/domain/entities/post.dart';
import 'package:flee_front/domain/repositories/post_repository.dart';

class CreatePostUseCase {
  final PostRepository postRepository;
  CreatePostUseCase(this.postRepository);

  Future<Post> call({
    required int userId,
    required int communityId,
    required String text,
    File? image,
  }) => postRepository.create(
    userId: userId,
    communityId: communityId,
    text: text,
    image: image,
  );
}
