sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkException extends AppException {
  const NetworkException(super.message);
}

final class AuthException extends AppException {
  const AuthException(super.message);
}

final class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

final class InvalidQrException extends AppException {
  const InvalidQrException(super.message);
}

final class UnknownException extends AppException {
  const UnknownException(super.message);
}
