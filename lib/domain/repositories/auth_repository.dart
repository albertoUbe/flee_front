import 'package:flee_front/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User?> login(String emailOrUser, String password);

  Future<User> signUp({
    required String name,
    required String username,
    required String email,
    required String password,
    required DateTime birthday,
  });
}
