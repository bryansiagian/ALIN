class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class AuthException extends ApiException {
  AuthException(String message) : super(message, 401);
}

class ValidationException extends ApiException {
  final Map<String, dynamic> errors;
  ValidationException(this.errors) : super("Input tidak valid", 422);
}