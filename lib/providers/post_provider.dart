import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../services/api_client.dart';

class PostProvider extends ChangeNotifier {
  final PostService _postService;
  final UserService _userService;

  PostProvider(this._postService, this._userService);

  List<PostModel> _feedPosts = [];
  final Map<int, List<PostModel>> _communityPosts = {};
  final Set<int> _votedPostIds = {};
  final Map<int, UserModel> _userCache = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<PostModel> get feedPosts => _feedPosts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<PostModel> communityPosts(int communityId) =>
      _communityPosts[communityId] ?? [];

  bool isVoted(int postId) => _votedPostIds.contains(postId);

  UserModel? authorOf(int userId) => _userCache[userId];

  Future<void> loadFeed({int? userId}) async {
    _setLoading(true);
    try {
      final posts = userId != null
          ? await _postService.getFeedByUser(userId)
          : await _postService.getAllPosts();
      _feedPosts = posts..sort((a, b) => b.postDate.compareTo(a.postDate));
      await _cacheAuthors(posts);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = 'Error al cargar el feed: ${e.statusCode}';
    } catch (_) {
      _errorMessage = 'Error de conexión';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCommunityPosts(int communityId) async {
    _setLoading(true);
    try {
      final posts = await _postService.getPostsByCommunity(communityId);
      _communityPosts[communityId] = posts
        ..sort((a, b) => b.postDate.compareTo(a.postDate));
      await _cacheAuthors(posts);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = 'Error al cargar posts: ${e.statusCode}';
    } catch (_) {
      _errorMessage = 'Error de conexión';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> vote(int postId, int userId) async {
    // Optimistic update
    final wasVoted = _votedPostIds.contains(postId);
    final delta = wasVoted ? -1 : 1;
    if (wasVoted) {
      _votedPostIds.remove(postId);
    } else {
      _votedPostIds.add(postId);
    }
    _applyVoteCountDelta(postId, delta);
    notifyListeners();

    try {
      await _postService.vote(postId, userId);
    } catch (_) {
      // Revert on error
      if (wasVoted) {
        _votedPostIds.add(postId);
      } else {
        _votedPostIds.remove(postId);
      }
      _applyVoteCountDelta(postId, -delta);
      notifyListeners();
    }
  }

  void _applyVoteCountDelta(int postId, int delta) {
    _feedPosts = _feedPosts.map((p) {
      if (p.id != postId) return p;
      return p.copyWith(voteCount: (p.voteCount + delta).clamp(0, 999999));
    }).toList();
    for (final key in _communityPosts.keys) {
      _communityPosts[key] = _communityPosts[key]!.map((p) {
        if (p.id != postId) return p;
        return p.copyWith(voteCount: (p.voteCount + delta).clamp(0, 999999));
      }).toList();
    }
  }

  Future<PostModel?> createPost(
    int userId,
    int communityId,
    String text, {
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    _setLoading(true);
    try {
      final post = await _postService.createPost(
        userId,
        communityId,
        text,
        imageBytes: imageBytes,
        imageName: imageName,
      );
      _communityPosts[communityId] = [
        post,
        ...(_communityPosts[communityId] ?? []),
      ];
      _feedPosts = [post, ..._feedPosts];
      _errorMessage = null;
      return post;
    } on ApiException catch (e) {
      _errorMessage = 'Error al crear post: ${e.message}';
      return null;
    } catch (_) {
      _errorMessage = 'Error de conexión';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deletePost(int postId, int communityId) async {
    try {
      await _postService.deletePost(postId);
      _feedPosts = _feedPosts.where((p) => p.id != postId).toList();
      if (_communityPosts.containsKey(communityId)) {
        _communityPosts[communityId] =
            _communityPosts[communityId]!.where((p) => p.id != postId).toList();
      }
      _votedPostIds.remove(postId);
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Error al eliminar post';
      notifyListeners();
      return false;
    }
  }

  Future<void> _cacheAuthors(List<PostModel> posts) async {
    final missingIds =
        posts.map((p) => p.userId).toSet().difference(_userCache.keys.toSet());
    if (missingIds.isEmpty) return;
    try {
      final users = await _userService.getAllUsers();
      for (final u in users) {
        _userCache[u.id] = u;
      }
    } catch (_) {
      // Author cache is best-effort; UI shows fallback if missing
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
