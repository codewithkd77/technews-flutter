import '../../models/news_article.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsArticle>> fetchNews();
  Future<List<NewsArticle>> fetchAiNews();
}

abstract class NewsLocalDataSource {
  Future<List<NewsArticle>> getBookmarkedNews();
  Future<void> saveBookmarkedNews(List<NewsArticle> articles);
  Future<bool> isArticleBookmarked(NewsArticle article);
  Future<void> addToBookmarks(NewsArticle article);
  Future<void> removeFromBookmarks(NewsArticle article);
  Future<void> clearBookmarks();
}
