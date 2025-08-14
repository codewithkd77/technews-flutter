class ApiConstants {
  static const String baseUrl = 'https://technews-aezz.onrender.com';
  static const String newsEndpoint = '/api/news';

  static const String newsApiUrl = '$baseUrl$newsEndpoint';
  static const String aiNewsApiUrl = 'YOUR-API-KEY-HERE';

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String aiApiKey = 'YOUR-AI-API-KEY-HERE';
}
