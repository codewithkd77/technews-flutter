/// API endpoints and configuration constants
class ApiConstants {
  // Base URLs
  static const String baseUrl = 'Your-api-key-here';
  static const String newsEndpoint = '/api/news';

  // Full API URLs
  static const String newsApiUrl = '$baseUrl$newsEndpoint';

  // AI News API (to be configured)
  static const String aiNewsApiUrl = 'YOUR-API-KEY-HERE';

  // HTTP Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeout configurations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // API Keys (should be moved to environment variables in production)
  static const String aiApiKey = 'YOUR-AI-API-KEY-HERE';
}
