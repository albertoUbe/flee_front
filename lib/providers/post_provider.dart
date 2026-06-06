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
  List<PostModel> _topPosts = [];
  final Map<int, List<PostModel>> _communityPosts = {};
  final Set<int> _votedPostIds = {};
  final Map<int, UserModel> _userCache = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Feed pagination
  int _feedPage = 1;
  bool _feedHasMore = false;
  bool _isLoadingMoreFeed = false;
  int? _feedUserId;

  // Community posts pagination
  final Map<int, int> _communityPostPages = {};
  final Map<int, bool> _communityPostHasMore = {};
  bool _isLoadingMoreCommunityPosts = false;

  List<PostModel> get feedPosts => _feedPosts;
  List<PostModel> get topPosts => _topPosts;
  bool get isLoading => _isLoading;
  bool get isLoadingMoreFeed => _isLoadingMoreFeed;
  bool get feedHasMore => _feedHasMore;
  bool get isLoadingMoreCommunityPosts => _isLoadingMoreCommunityPosts;
  String? get errorMessage => _errorMessage;

  List<PostModel> communityPosts(int communityId) =>
      _communityPosts[communityId] ?? [];

  bool communityPostsHasMore(int communityId) =>
      _communityPostHasMore[communityId] ?? false;

  bool isVoted(int postId) => _votedPostIds.contains(postId);

  UserModel? authorOf(int userId) => _userCache[userId];

  Future<void> loadFeed({int? userId}) async {
    _feedPage = 1;
    _feedHasMore = false;
    _feedUserId = userId;
    _setLoading(true);
    try {
      if (userId != null) {
        final result = await _postService.getFeedByUser(userId, page: 1);
        _feedPosts = result.items..sort((a, b) => b.postDate.compareTo(a.postDate));
        _feedHasMore = result.hasMore;
      } else {
        final posts = await _postService.getAllPosts();
        _feedPosts = posts..sort((a, b) => b.postDate.compareTo(a.postDate));
        _feedHasMore = false;
      }
      await _cacheAuthors(_feedPosts);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = 'Error al cargar el feed: ${e.statusCode}';
    } catch (_) {
      _errorMessage = 'Error de conexión';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMoreFeed() async {
    if (_isLoadingMoreFeed || !_feedHasMore || _feedUserId == null) return;
    _isLoadingMoreFeed = true;
    notifyListeners();
    try {
      _feedPage++;
      final result =
          await _postService.getFeedByUser(_feedUserId!, page: _feedPage);
      _feedPosts = [..._feedPosts, ...result.items];
      _feedHasMore = result.hasMore;
      await _cacheAuthors(result.items);
    } catch (_) {
      _feedPage--;
    } finally {
      _isLoadingMoreFeed = false;
      notifyListeners();
    }
  }

  Future<void> loadTopPosts() async {
    _setLoading(true);
    try {
      _topPosts = await _postService.getTopPosts();
      await _cacheAuthors(_topPosts);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = 'Error al cargar top posts: ${e.statusCode}';
    } catch (_) {
      _errorMessage = 'Error de conexión';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCommunityPosts(int communityId) async {
    _communityPostPages[communityId] = 1;
    _communityPostHasMore[communityId] = false;
    _setLoading(true);
    try {
      final result =
          await _postService.getPostsByCommunity(communityId, page: 1);
      _communityPosts[communityId] = result.items
        ..sort((a, b) => b.postDate.compareTo(a.postDate));
      _communityPostHasMore[communityId] = result.hasMore;
      await _cacheAuthors(result.items);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = 'Error al cargar posts: ${e.statusCode}';
    } catch (_) {
      _errorMessage = 'Error de conexión';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMoreCommunityPosts(int communityId) async {
    if (_isLoadingMoreCommunityPosts ||
        !(_communityPostHasMore[communityId] ?? false)) return;
    _isLoadingMoreCommunityPosts = true;
    notifyListeners();
    try {
      final nextPage = (_communityPostPages[communityId] ?? 1) + 1;
      final result =
          await _postService.getPostsByCommunity(communityId, page: nextPage);
      _communityPosts[communityId] = [
        ...(_communityPosts[communityId] ?? []),
        ...result.items,
      ];
      _communityPostPages[communityId] = nextPage;
      _communityPostHasMore[communityId] = result.hasMore;
      await _cacheAuthors(result.items);
    } catch (_) {
      // silencioso — el usuario puede reintentar haciendo scroll
    } finally {
      _isLoadingMoreCommunityPosts = false;
      notifyListeners();
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
