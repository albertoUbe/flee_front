import 'package:flee_front/domain/entities/user.dart';
import 'package:flee_front/domain/repositories/auth_repository.dart';
import 'package:flee_front/core/exceptions/exceptions.dart';

class LoginUseCase {
  final AuthRepository authRepository;
  LoginUseCase(this.authRepository);

  Future<User?> call(String emailOrUser, String password) async {
    final bool fieldEmpty =
        (emailOrUser.trim().isEmpty || password.trim().isEmpty);

    if (fieldEmpty) {
      throw EmptyFieldsFailure();
    }

    return await authRepository.login(emailOrUser, password);
  }
}
