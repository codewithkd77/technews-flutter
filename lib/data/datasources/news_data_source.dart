import '../../models/news_article.dart';

/// Abstract interface for remote news data sources
abstract class NewsRemoteDataSource {
  /// Fetches general tech news from remote API
  Future<List<NewsArticle>> fetchNews();

  /// Fetches AI-specific news from remote API
  Future<List<NewsArticle>> fetchAiNews();
}

/// Abstract interface for local news data sources
abstract class NewsLocalDataSource {
  /// Loads bookmarked news from local storage
  Future<List<NewsArticle>> getBookmarkedNews();

  /// Saves bookmarked news to local storage
  Future<void> saveBookmarkedNews(List<NewsArticle> articles);

  /// Checks if a specific article is bookmarked
  Future<bool> isArticleBookmarked(NewsArticle article);

  /// Adds an article to bookmarks
  Future<void> addToBookmarks(NewsArticle article);

  /// Removes an article from bookmarks
  Future<void> removeFromBookmarks(NewsArticle article);

  /// Clears all bookmarked news
  Future<void> clearBookmarks();
}
