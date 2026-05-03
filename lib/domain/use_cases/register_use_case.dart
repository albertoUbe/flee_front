import 'package:flee_front/core/common/constants.dart';
import 'package:flee_front/core/exceptions/exceptions.dart';
import 'package:flee_front/domain/entities/user.dart';
import 'package:flee_front/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository authRepository;
  RegisterUseCase(this.authRepository);

  Future<User> call({
    required String name,
    required String username,
    required String email,
    required String password,
    required DateTime? birthday,
  }) async {
    final bool fieldEmpty =
        (name.trim().isEmpty ||
        username.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty ||
        birthday == null);

    if (fieldEmpty) {
      throw EmptyFieldsFailure();
    }

    if (password.length < Constants.minPasswordLength) {
      throw WeakPasswordFailure();
    }

    if (!User.isAdultCheck(birthday)) {
      throw UnderageFailure();
    }

    return await authRepository.signUp(
      name: name,
      username: username,
      email: email,
      password: password,
      birthday: birthday,
    );
  }
}
