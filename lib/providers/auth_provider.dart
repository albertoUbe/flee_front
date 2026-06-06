import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../core/constants/api_constants.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final UserService _userService;
  final SharedPreferences _prefs;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._userService, this._prefs);

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> tryRestoreSession() async {
    final jsonStr = _prefs.getString(ApiConstants.userPrefsKey);
    if (jsonStr == null) return;
    try {
      final stored = UserModel.fromJsonString(jsonStr);
      _currentUser = await _userService.verify(stored.id);
      await _persist(_currentUser!);
    } catch (_) {
      await _prefs.remove(ApiConstants.userPrefsKey);
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      _currentUser = await _userService.signIn(email, password);
      await _persist(_currentUser!);
      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = _parseError(e.message, 'Credenciales incorrectas');
      return false;
    } catch (_) {
      _errorMessage = 'Error de conexión con el servidor';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp(
    String email,
    String name,
    String password,
    String confirmPassword,
  ) async {
    _setLoading(true);
    try {
      _currentUser = await _userService.signUp(email, name, password, confirmPassword);
      await _persist(_currentUser!);
      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = _parseError(e.message, 'Error al registrarse');
      return false;
    } catch (_) {
      _errorMessage = 'Error de conexión con el servidor';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> editProfile(
    String name,
    String bio, {
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    _setLoading(true);
    try {
      final updated = await _userService.editProfile(
        _currentUser!.id,
        name,
        bio,
        imageBytes: imageBytes,
        imageFileName: imageFileName,
      );
      _currentUser = updated;
      await _persist(updated);
      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = _parseError(e.message, 'Error al actualizar perfil');
      return false;
    } catch (_) {
      _errorMessage = 'Error de conexión con el servidor';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAccount() async {
    if (_currentUser == null) return;
    await _userService.deleteUser(_currentUser!.id);
    await signOut();
  }

  Future<void> refreshUser() async {
    if (_currentUser == null) return;
    try {
      _currentUser = await _userService.verify(_currentUser!.id);
      await _persist(_currentUser!);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> signOut() async {
    await _prefs.remove(ApiConstants.userPrefsKey);
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _persist(UserModel user) async {
    await _prefs.setString(ApiConstants.userPrefsKey, user.toJsonString());
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _parseError(String raw, String fallback) {
    if (raw.contains('email') || raw.contains('Email')) {
      return 'El email ya está registrado';
    }
    if (raw.contains('password') || raw.contains('Password')) {
      return 'Las contraseñas no coinciden';
    }
    if (raw.trim().isNotEmpty && raw.length < 120) return raw.trim();
    return fallback;
  }
}
