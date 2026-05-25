import 'package:flee_front/core/exceptions/exceptions.dart';
import 'package:flee_front/domain/entities/user.dart';
import 'package:flee_front/domain/use_cases/authentication/sign_in_use_case.dart';
import 'package:flutter/foundation.dart';

class SignInViewModel extends ChangeNotifier {
  final SignInUseCase signInUseCase;
  SignInViewModel(this.signInUseCase);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? _user;
  User? get user => _user;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await signInUseCase(email, password);
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
