import 'package:flee_front/core/exceptions/exceptions.dart';
import 'package:flee_front/domain/entities/user.dart';
import 'package:flee_front/domain/use_cases/register_use_case.dart';
import 'package:flutter/foundation.dart';

class RegisterViewModel extends ChangeNotifier {
  final RegisterUseCase registerUseCase;

  RegisterViewModel(this.registerUseCase);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? _user;
  User? get user => _user;

  Future<void> signUp({
    required String name,
    required String username,
    required String email,
    required String password,
    required DateTime? birthday,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await registerUseCase(
        name: name,
        username: username,
        email: email,
        password: password,
        birthday: birthday,
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
