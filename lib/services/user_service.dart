import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class UserService {
  Future<UserModel> signIn(String email, String password) async {
    final data = await ApiClient.post(
      ApiConstants.signIn(),
      {'email': email, 'password': password},
    );
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<UserModel> signUp(
    String email,
    String name,
    String password,
    String confirmPassword,
  ) async {
    final data = await ApiClient.post(
      ApiConstants.signUp(),
      {
        'email': email,
        'name': name,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<UserModel> verify(int id) async {
    final data = await ApiClient.get(ApiConstants.verify(id));
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<UserModel> editProfile(
    int id,
    String name,
    String bio,
    String avatarUrl,
  ) async {
    final data = await ApiClient.put(
      ApiConstants.editProfile(id),
      {'name': name, 'bio': bio, 'avatarUrl': avatarUrl},
    );
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<UserModel>> getAllUsers() async {
    final data = await ApiClient.get(ApiConstants.allUsers());
    return (data as List)
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<UserModel>> getUsersByCommunity(int communityId) async {
    final data = await ApiClient.get(ApiConstants.usersByCommunity(communityId));
    return (data as List)
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<UserModel>> getUsersByVotes(int postId) async {
    final data = await ApiClient.get(ApiConstants.usersByVotes(postId));
    return (data as List)
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteUser(int id) async {
    await ApiClient.delete(ApiConstants.deleteUser(id));
  }

  Future<void> forgotPassword(String email) async {
    await ApiClient.post(ApiConstants.forgotPassword(), {'email': email});
  }

  Future<void> resetPassword(
    String token,
    String newPassword,
    String confirmPassword,
  ) async {
    await ApiClient.post(
      ApiConstants.resetPassword(),
      {
        'token': token,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }
}
