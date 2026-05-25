import 'package:flee_front/core/exceptions/exceptions.dart';
import 'package:flee_front/domain/entities/post.dart';
import 'package:flee_front/domain/use_cases/posts/all_post_use_case.dart';
import 'package:flee_front/domain/use_cases/posts/create_post_use_case.dart';
import 'package:flee_front/domain/use_cases/posts/delete_post_use_case.dart';
import 'package:flee_front/domain/use_cases/posts/post_by_community_use_case.dart';
import 'package:flee_front/domain/use_cases/posts/vote_post_use_case.dart';
import 'package:flutter/foundation.dart';

class PostViewModel extends ChangeNotifier {
  final AllPostUseCase allPostUseCase;
  final PostByCommunityUseCase postByCommunityUseCase;
  final CreatePostUseCase createPostUseCase;
  final DeletePostUseCase deletePostUseCase;
  final VotePostUseCase votePostUseCase;

  PostViewModel({
    required this.allPostUseCase,
    required this.postByCommunityUseCase,
    required this.createPostUseCase,
    required this.deletePostUseCase,
    required this.votePostUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  Future<void> loadAll() async {
    _start();
    try {
      _posts = await allPostUseCase();
    } on Exceptions catch (e) {
      _errorMessage = e.message;
    } finally {
      _end();
    }
  }

  Future<void> loadByCommunity(int communityId) async {
    _start();
    try {
      _posts = await postByCommunityUseCase(communityId: communityId);
    } on Exceptions catch (e) {
      _errorMessage = e.message;
    } finally {
      _end();
    }
  }

  Future<bool> create({
    required int userId,
    required int communityId,
    required String text,
  }) async {
    _start();
    try {
      final post = await createPostUseCase(
        userId: userId,
        communityId: communityId,
        text: text,
      );
      _posts.insert(0, post);
      return true;
    } on Exceptions catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _end();
    }
  }

  Future<void> delete(int id) async {
    try {
      await deletePostUseCase(id: id);
      _posts.removeWhere((p) => p.id == id);
      notifyListeners();
    } on Exceptions catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> vote(int postId, int userId) async {
    try {
      await votePostUseCase(postId: postId, userId: userId);
    } on Exceptions catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  void _start() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _end() {
    _isLoading = false;
    notifyListeners();
  }
}
