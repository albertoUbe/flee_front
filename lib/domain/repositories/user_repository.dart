import 'package:flee_front/domain/entities/user.dart';

abstract class UserRepository {
  Future<User> signIn(String email, String password);

  Future<User> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  });
}
