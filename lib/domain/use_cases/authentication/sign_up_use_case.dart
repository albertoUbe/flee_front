import 'package:flee_front/domain/entities/user.dart';
import 'package:flee_front/domain/repositories/user_repository.dart';

class SignUpUseCase {
  final UserRepository userRepository;
  SignUpUseCase(this.userRepository);

  Future<User> call({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) => userRepository.signUp(
    name: name,
    email: email,
    password: password,
    confirmPassword: confirmPassword,
  );
}
