import 'package:flee_front/data/services/api_service.dart';
import 'package:flee_front/domain/entities/user.dart';
import 'package:flee_front/domain/repositories/user_repository.dart';

class AuthRepositoryImpl implements UserRepository {
  final ApiService api;
  AuthRepositoryImpl(this.api);

  @override
  Future<User> signIn(String email, String password) async {
    final json = await api.signIn(email, password);
    return User.fromJson(json);
  }

  @override
  Future<User> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final json = await api.signUp(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    return User.fromJson(json);
  }
}
