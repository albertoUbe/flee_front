import 'package:flee_front/core/common/constants.dart';

class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final String password;
  final DateTime birthday;
  final String? picture;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.birthday,
    this.picture,
  });

  int get age => calculateAge(birthday);

  bool get isAdult => age >= Constants.minUserAge;

  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty)
      .take(2)
      .map((s) => s[0].toUpperCase())
      .join();

  static bool isAdultCheck(DateTime birthday) {
    return calculateAge(birthday) >= Constants.minUserAge;
  }

  static int calculateAge(DateTime birthday) {
    final DateTime now = DateTime.now();
    int age = now.year - birthday.year;

    final bool isBirthday =
        (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day));

    return isBirthday ? age - 1 : age;
  }
}
