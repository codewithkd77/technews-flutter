import 'package:equatable/equatable.dart';
import '../../models/news_article.dart';

/// Represents the different states of news loading and management
abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object> get props => [];
}

/// Initial state when the BLoC is first created
class NewsInitial extends NewsState {
  const NewsInitial();
}

/// State when news is being loaded from the API
class NewsLoading extends NewsState {
  const NewsLoading();
}

/// State when news has been successfully loaded
class NewsLoaded extends NewsState {
  final List<NewsArticle> articles;
  final List<NewsArticle> bookmarkedArticles;

  const NewsLoaded({
    required this.articles,
    required this.bookmarkedArticles,
  });

  /// Creates a copy of the loaded state with updated data
  NewsLoaded copyWith({
    List<NewsArticle>? articles,
    List<NewsArticle>? bookmarkedArticles,
  }) {
    return NewsLoaded(
      articles: articles ?? this.articles,
      bookmarkedArticles: bookmarkedArticles ?? this.bookmarkedArticles,
    );
  }

  /// Checks if a specific article is bookmarked
  bool isBookmarked(NewsArticle article) {
    return bookmarkedArticles
        .any((bookmarked) => bookmarked.title == article.title);
  }

  @override
  List<Object> get props => [articles, bookmarkedArticles];
}

/// State when there's an error loading news
class NewsError extends NewsState {
  final String message;

  const NewsError(this.message);

  @override
  List<Object> get props => [message];
}
