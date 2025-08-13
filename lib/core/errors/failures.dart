import 'package:equatable/equatable.dart';

/// Base failure class for handling errors in the app
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Failure related to network connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Failure related to API or server errors
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required String message,
    this.statusCode,
    String? code,
  }) : super(message: message, code: code);

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Failure related to local storage or cache
class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Failure related to data parsing or validation
class ParseFailure extends Failure {
  const ParseFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// General application failure
class GeneralFailure extends Failure {
  const GeneralFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}
