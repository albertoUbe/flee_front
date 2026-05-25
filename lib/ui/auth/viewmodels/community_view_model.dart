import 'package:flee_front/core/exceptions/exceptions.dart';
import 'package:flee_front/domain/entities/community.dart';
import 'package:flee_front/domain/use_cases/communities/all_communities_use_case.dart';
import 'package:flee_front/domain/use_cases/communities/community_by_user_use_case.dart';
import 'package:flee_front/domain/use_cases/communities/create_community_use_case.dart';
import 'package:flee_front/domain/use_cases/communities/follow_unfollow_use_case.dart';
import 'package:flee_front/domain/use_cases/communities/manage_admin_use_case.dart';
import 'package:flutter/foundation.dart';

class CommunityViewModel extends ChangeNotifier {
  final AllCommunitiesUseCase allCommunitiesUseCase;
  final CommunityByUserUseCase communityByUserUseCase;
  final CreateCommunityUseCase createCommunityUseCase;
  final FollowUnfollowUseCase followUnfollowUseCase;
  final ManageAdminUseCase manageAdminUseCase;

  CommunityViewModel({
    required this.allCommunitiesUseCase,
    required this.communityByUserUseCase,
    required this.createCommunityUseCase,
    required this.followUnfollowUseCase,
    required this.manageAdminUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Community> _allCommunities = [];
  List<Community> get allCommunities => _allCommunities;

  List<Community> _myCommunities = [];
  List<Community> get myCommunities => _myCommunities;

  Future<void> loadAll() async {
    _start();
    try {
      _allCommunities = await allCommunitiesUseCase();
    } on Exceptions catch (e) {
      _errorMessage = e.message;
    } finally {
      _end();
    }
  }

  Future<void> loadMyCommunities(int userId) async {
    _start();
    try {
      _myCommunities = await communityByUserUseCase(userId);
    } on Exceptions catch (e) {
      _errorMessage = e.message;
    } finally {
      _end();
    }
  }

  Future<bool> create({
    required int creatorId,
    required String name,
    required String description,
    required int duration,
  }) async {
    _start();
    try {
      final community = await createCommunityUseCase(
        creatorId: creatorId,
        name: name,
        description: description,
        duration: duration,
      );
      _allCommunities.insert(0, community);
      return true;
    } on Exceptions catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _end();
    }
  }

  Future<void> followUnfollow(int userId, int communityId) async {
    try {
      await followUnfollowUseCase(userId: userId, communityId: communityId);
      await loadMyCommunities(userId);
    } on Exceptions catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> manageAdmin(int userId, int ownerId, int communityId) async {
    try {
      await manageAdminUseCase(
        userId: userId,
        ownerId: ownerId,
        communityId: communityId,
      );
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
