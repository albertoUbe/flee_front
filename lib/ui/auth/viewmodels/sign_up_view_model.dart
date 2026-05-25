import 'package:flee_front/core/exceptions/exceptions.dart';
import 'package:flee_front/domain/entities/user.dart';
import 'package:flee_front/domain/use_cases/authentication/sign_up_use_case.dart';
import 'package:flutter/foundation.dart';

class SignUpViewModel extends ChangeNotifier {
  final SignUpUseCase signUpUseCase;
  SignUpViewModel(this.signUpUseCase);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? _user;
  User? get user => _user;

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await signUpUseCase(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
    } on Exceptions catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
