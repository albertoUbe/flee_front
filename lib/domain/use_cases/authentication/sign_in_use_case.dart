import 'package:flee_front/domain/entities/user.dart';
import 'package:flee_front/domain/repositories/user_repository.dart';

class SignInUseCase {
  final UserRepository userRepository;
  SignInUseCase(this.userRepository);

  Future<User> call(String email, String password) =>
      userRepository.signIn(email, password);
}
