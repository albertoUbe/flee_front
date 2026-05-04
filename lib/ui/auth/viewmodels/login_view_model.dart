import 'package:flee_front/core/exceptions/exceptions.dart';
import 'package:flee_front/domain/entities/user.dart';
import 'package:flee_front/domain/use_cases/login_use_case.dart';
import 'package:flutter/foundation.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  LoginViewModel(this.loginUseCase);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? _user;
  User? get user => _user;

  Future<void> login(String emailOrUser, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await loginUseCase(emailOrUser, password);
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
