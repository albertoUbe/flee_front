class UserSignUpModel {
  final String email;
  final String name;
  final String password;
  final String confirmPassword;

  UserSignUpModel({
    required this.email,
    required this.name,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }
}
