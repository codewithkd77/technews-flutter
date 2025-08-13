import '../../core/errors/exceptions.dart';
import '../../models/news_article.dart';
import '../datasources/news_data_source.dart';

/// Repository interface for news-related operations
abstract class NewsRepository {
  /// Fetches general tech news
  Future<List<NewsArticle>> fetchNews();

  /// Fetches AI-specific news
  Future<List<NewsArticle>> fetchAiNews();

  /// Loads bookmarked news from local storage
  Future<List<NewsArticle>> loadBookmarkedNews();

  /// Checks if a specific news article is bookmarked
  Future<bool> isNewsBookmarked(NewsArticle article);

  /// Adds a news article to bookmarks
  Future<List<NewsArticle>> addToBookmarks(NewsArticle article);

  /// Removes a news article from bookmarks
  Future<List<NewsArticle>> removeFromBookmarks(NewsArticle article);

  /// Clears all bookmarks
  Future<void> clearAllBookmarks();
}

/// Implementation of NewsRepository that combines remote and local data sources
class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<NewsArticle>> fetchNews() async {
    try {
      return await remoteDataSource.fetchNews();
    } on NetworkException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Repository: Failed to fetch news - $e');
    }
  }

  @override
  Future<List<NewsArticle>> fetchAiNews() async {
    try {
      return await remoteDataSource.fetchAiNews();
    } on NetworkException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Repository: Failed to fetch AI news - $e');
    }
  }

  @override
  Future<List<NewsArticle>> loadBookmarkedNews() async {
    try {
      return await localDataSource.getBookmarkedNews();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw Exception('Repository: Failed to load bookmarked news - $e');
    }
  }

  @override
  Future<bool> isNewsBookmarked(NewsArticle article) async {
    try {
      return await localDataSource.isArticleBookmarked(article);
    } catch (e) {
      // Return false if unable to check (graceful degradation)
      return false;
    }
  }

  @override
  Future<List<NewsArticle>> addToBookmarks(NewsArticle article) async {
    try {
      await localDataSource.addToBookmarks(article);
      return await localDataSource.getBookmarkedNews();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw Exception('Repository: Failed to add to bookmarks - $e');
    }
  }

  @override
  Future<List<NewsArticle>> removeFromBookmarks(NewsArticle article) async {
    try {
      await localDataSource.removeFromBookmarks(article);
      return await localDataSource.getBookmarkedNews();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw Exception('Repository: Failed to remove from bookmarks - $e');
    }
  }

  @override
  Future<void> clearAllBookmarks() async {
    try {
      await localDataSource.clearBookmarks();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw Exception('Repository: Failed to clear bookmarks - $e');
    }
  }
}
