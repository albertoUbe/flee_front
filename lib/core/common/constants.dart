class Constants {
  static const String baseUrl = "http://localhost:5076/api";

  static const int minPasswordLength = 8;

  static const String errorRequiredField = "Required.";
  static const String errorWeakPassword =
      "Weak password, it must be at least $minPasswordLength characters long.";
  static const String errorServer =
      "An error has occurred on the server. Please try again later.";
  static const String errorConnection = "There is no internet connection.";
  static const String errorInvalidCredentials =
      "Incorrect email address or password.";
  static const String errorUserAlreadyExists =
      "This email address is already registered.";
  static const String errorUnknown = "An unexpected error has occurred.";
  static const String errorUserNotFound = "User not found.";
}
