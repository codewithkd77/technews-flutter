/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  const AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() {
    return 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Exception thrown when there's a network connectivity issue
class NetworkException extends AppException {
  const NetworkException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
        );
}

/// Exception thrown when API returns an error
class ApiException extends AppException {
  final int? statusCode;

  const ApiException({
    required String message,
    this.statusCode,
    String? code,
    dynamic originalException,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
        );

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Exception thrown when there's an issue with local storage
class CacheException extends AppException {
  const CacheException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
        );
}

/// Exception thrown when data parsing fails
class ParseException extends AppException {
  const ParseException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
        );
}

/// Exception thrown when a requested resource is not found
class NotFoundException extends AppException {
  const NotFoundException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
        );
}
