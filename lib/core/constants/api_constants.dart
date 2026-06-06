import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiConstants {
  static const String _prodUrl = 'https://fleeback-production.up.railway.app';

  static String get baseUrl => _prodUrl;

  static const String userPrefsKey = 'flee_current_user';

  // User
  static String signIn() => '$baseUrl/api/user/signin';
  static String signUp() => '$baseUrl/api/user/signup';
  static String verify(int id) => '$baseUrl/api/user/verify/$id';
  static String editProfile(int id) => '$baseUrl/api/user/editprofile/$id';
  static String allUsers() => '$baseUrl/api/user';
  static String usersByCommunity(int communityId) =>
      '$baseUrl/api/user/community/$communityId';
  static String usersByVotes(int postId) => '$baseUrl/api/user/votes/$postId';
  static String deleteUser(int id) => '$baseUrl/api/user/$id';
  static String forgotPassword() => '$baseUrl/api/user/forgot-password';
  static String resetPassword() => '$baseUrl/api/user/reset-password';

  // Community
  static String allCommunities() => '$baseUrl/api/community';
  static String communitiesByUser(int userId) =>
      '$baseUrl/api/community/user/$userId';
  static String createCommunity() => '$baseUrl/api/community';
  static String editCommunity(int id) => '$baseUrl/api/community/edit/$id';
  static String deleteCommunity(int id) => '$baseUrl/api/community/$id';
  static String followCommunity(int communityId, int userId) =>
      '$baseUrl/api/community/$communityId/follow/$userId';
  static String manageAdmin(int communityId, int ownerId, int userId) =>
      '$baseUrl/api/community/$communityId/$ownerId/admin/$userId';

  // Post
  static String allPosts() => '$baseUrl/api/post';
  static String postsByCommunity(int communityId) =>
      '$baseUrl/api/post/community/$communityId';
  static String createPost() => '$baseUrl/api/post';
  static String votePost(int postId, int userId) =>
      '$baseUrl/api/post/$postId/vote/$userId';
  static String deletePost(int id) => '$baseUrl/api/post/$id';

  // Plan
  static String allPlans() => '$baseUrl/api/plan';
}
