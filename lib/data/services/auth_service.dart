import 'dart:async';
import 'package:flee_front/core/exceptions/exceptions.dart';

class AuthService {
  final List<Map<String, dynamic>> _testUsers = [
    {
      "id": "1",
      "name": "Alberto Test",
      "username": "alberto",
      "email": "alberto@test.com",
      "password": "password123",
      "birthday": DateTime(1998, 5, 20),
      "image": null,
    },
  ];

  Future<Map<String, dynamic>?> login(
    String emailOrUser,
    String password,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    final user = _testUsers.firstWhere(
      (u) =>
          (u["email"] == emailOrUser || u["username"] == emailOrUser) &&
          u["password"] == password,
      orElse: () => {},
    );

    if (user.isEmpty) return null;
    return user;
  }

  Future<Map<String, dynamic>> signUp(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));

    final exists = _testUsers.any(
      (u) => u["email"] == data["email"] || u["username"] == data["username"],
    );

    if (exists) {
      throw UserAlreadyExistsFailure();
    }

    final newUser = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      ...data,
    };

    _testUsers.add(newUser);
    return newUser;
  }
}
