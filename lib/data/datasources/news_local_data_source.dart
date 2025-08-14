import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../models/news_article.dart';
import 'news_data_source.dart';

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  final SharedPreferences sharedPreferences;

  NewsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<NewsArticle>> getBookmarkedNews() async {
    try {
      final savedBookmarks =
          sharedPreferences.getString(AppConstants.bookmarkedNewsKey);

      if (savedBookmarks != null) {
        final List<dynamic> bookmarkedData = jsonDecode(savedBookmarks);
        return bookmarkedData
            .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      throw CacheException(
        message: 'Failed to load bookmarked news from local storage',
        originalException: e,
      );
    }
  }

  @override
  Future<void> saveBookmarkedNews(List<NewsArticle> articles) async {
    try {
      final bookmarkedData =
          articles.map((article) => article.toJson()).toList();
      await sharedPreferences.setString(
        AppConstants.bookmarkedNewsKey,
        jsonEncode(bookmarkedData),
      );
    } catch (e) {
      throw CacheException(
        message: 'Failed to save bookmarked news to local storage',
        originalException: e,
      );
    }
  }

  @override
  Future<bool> isArticleBookmarked(NewsArticle article) async {
    try {
      final bookmarkedNews = await getBookmarkedNews();
      return bookmarkedNews
          .any((bookmarked) => bookmarked.title == article.title);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> addToBookmarks(NewsArticle article) async {
    try {
      final bookmarkedNews = await getBookmarkedNews();

      if (!bookmarkedNews
          .any((bookmarked) => bookmarked.title == article.title)) {
        bookmarkedNews.add(article);
        await saveBookmarkedNews(bookmarkedNews);
      }
    } catch (e) {
      throw CacheException(
        message: 'Failed to add article to bookmarks',
        originalException: e,
      );
    }
  }

  @override
  Future<void> removeFromBookmarks(NewsArticle article) async {
    try {
      final bookmarkedNews = await getBookmarkedNews();
      bookmarkedNews
          .removeWhere((bookmarked) => bookmarked.title == article.title);
      await saveBookmarkedNews(bookmarkedNews);
    } catch (e) {
      throw CacheException(
        message: 'Failed to remove article from bookmarks',
        originalException: e,
      );
    }
  }

  @override
  Future<void> clearBookmarks() async {
    try {
      await sharedPreferences.remove(AppConstants.bookmarkedNewsKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear bookmarks',
        originalException: e,
      );
    }
  }
}
