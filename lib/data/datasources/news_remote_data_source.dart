import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/network_utils.dart';
import '../../models/news_article.dart';
import 'news_data_source.dart';

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final http.Client httpClient;

  NewsRemoteDataSourceImpl({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  @override
  Future<List<NewsArticle>> fetchNews() async {
    if (!await NetworkUtils.hasInternetConnection()) {
      throw const NetworkException(
        message: 'No internet connection available',
        code: 'NO_INTERNET',
      );
    }

    try {
      final response = await httpClient
          .get(
            Uri.parse(ApiConstants.newsApiUrl),
            headers: ApiConstants.defaultHeaders,
          )
          .timeout(ApiConstants.connectionTimeout);

      NetworkUtils.handleHttpResponse(response.statusCode, response.body);

      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData
          .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
          .toList();
    } on NetworkException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse news data',
        originalException: e,
      );
    }
  }

  @override
  Future<List<NewsArticle>> fetchAiNews() async {
    if (!await NetworkUtils.hasInternetConnection()) {
      throw const NetworkException(
        message: 'No internet connection available',
        code: 'NO_INTERNET',
      );
    }

    try {
      if (ApiConstants.aiNewsApiUrl == 'YOUR-API-KEY-HERE') {
        throw const ApiException(
          message: 'AI News API not configured',
          code: 'API_NOT_CONFIGURED',
        );
      }

      final response = await httpClient
          .get(
            Uri.parse(ApiConstants.aiNewsApiUrl),
            headers: ApiConstants.defaultHeaders,
          )
          .timeout(ApiConstants.connectionTimeout);

      NetworkUtils.handleHttpResponse(response.statusCode, response.body);

      final dynamic jsonData = json.decode(response.body);

      if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
        final List<dynamic> newsData = jsonData['data'] as List<dynamic>;
        return newsData
            .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (jsonData is List<dynamic>) {
        return jsonData
            .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw const ParseException(
          message: 'Unexpected AI news API response format',
          code: 'INVALID_RESPONSE_FORMAT',
        );
      }
    } on NetworkException {
      rethrow;
    } on ApiException {
      rethrow;
    } on ParseException {
      rethrow;
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse AI news data',
        originalException: e,
      );
    }
  }
}
