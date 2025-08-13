import 'dart:io';
import '../errors/exceptions.dart';

/// Network utility functions and connectivity checks
class NetworkUtils {
  /// Checks if the device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Handles HTTP response and throws appropriate exceptions
  static void handleHttpResponse(int statusCode, String body) {
    switch (statusCode) {
      case 200:
      case 201:
        // Success - no exception needed
        break;
      case 400:
        throw const ApiException(
          message: 'Bad Request - Invalid parameters',
          statusCode: 400,
        );
      case 401:
        throw const ApiException(
          message: 'Unauthorized - Invalid authentication',
          statusCode: 401,
        );
      case 403:
        throw const ApiException(
          message: 'Forbidden - Access denied',
          statusCode: 403,
        );
      case 404:
        throw const ApiException(
          message: 'Not Found - Resource does not exist',
          statusCode: 404,
        );
      case 429:
        throw const ApiException(
          message: 'Too Many Requests - Rate limit exceeded',
          statusCode: 429,
        );
      case 500:
        throw const ApiException(
          message: 'Internal Server Error',
          statusCode: 500,
        );
      case 502:
        throw const ApiException(
          message: 'Bad Gateway - Server is temporarily unavailable',
          statusCode: 502,
        );
      case 503:
        throw const ApiException(
          message: 'Service Unavailable - Server is temporarily down',
          statusCode: 503,
        );
      default:
        throw ApiException(
          message: 'Unknown error occurred - Status: $statusCode',
          statusCode: statusCode,
        );
    }
  }

  /// Validates if a URL is properly formatted
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Extracts domain from URL
  static String? extractDomain(String? url) {
    if (!isValidUrl(url)) return null;

    try {
      final uri = Uri.parse(url!);
      return uri.host;
    } catch (e) {
      return null;
    }
  }
}
