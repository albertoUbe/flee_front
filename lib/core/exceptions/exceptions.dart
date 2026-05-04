import 'package:flee_front/core/common/constants.dart';

abstract class Exceptions implements Exception {
  final String message;
  Exceptions(this.message);
}

class EmptyFieldsFailure extends Exceptions {
  EmptyFieldsFailure() : super(Constants.errorRequiredField);
}

class WeakPasswordFailure extends Exceptions {
  WeakPasswordFailure() : super(Constants.errorWeakPassword);
}

class UnderageFailure extends Exceptions {
  UnderageFailure() : super(Constants.errorUnderage);
}

class ServerFailure extends Exceptions {
  ServerFailure([String? message]) : super(message ?? Constants.errorServer);
}

class NetworkFailure extends Exceptions {
  NetworkFailure() : super(Constants.errorConnection);
}

class UserAlreadyExistsFailure extends Exceptions {
  UserAlreadyExistsFailure() : super(Constants.errorUserAlreadyExists);
}

class AuthInvalidFailure extends Exceptions {
  AuthInvalidFailure() : super(Constants.errorInvalidCredentials);
}

class UserNotFoundFailure extends Exceptions {
  UserNotFoundFailure() : super(Constants.errorUserNotFound);
}
