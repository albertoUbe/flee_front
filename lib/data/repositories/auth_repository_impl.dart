import 'package:flee_front/core/exceptions/exceptions.dart';
import 'package:flee_front/data/services/auth_service.dart';
import 'package:flee_front/domain/entities/user.dart';
import 'package:flee_front/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;
  AuthRepositoryImpl(this.authService);

  @override
  Future<User?> login(String emailOrUser, String password) async {
    try {
      final json = await authService.login(emailOrUser, password);

      if (json == null) {
        throw AuthInvalidFailure();
      }

      return _mapToEntity(json);
    } on AuthInvalidFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure();
    }
  }

  @override
  Future<User> signUp({
    required String name,
    required String username,
    required String email,
    required String password,
    required DateTime birthday,
  }) async {
    try {
      final json = await authService.signUp({
        "name": name,
        "username": username,
        "email": email,
        "password": password,
        "birthday": birthday,
      });

      return _mapToEntity(json);
    } on UserAlreadyExistsFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure();
    }
  }

  User _mapToEntity(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      name: json["name"],
      username: json["username"],
      email: json["email"],
      password: json["password"],
      birthday: json["birthday"],
      picture: json["image"],
    );
  }
}
