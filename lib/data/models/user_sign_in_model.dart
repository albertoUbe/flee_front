class UserSignInModel {
  final String email;
  final String password;

  UserSignInModel({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}
