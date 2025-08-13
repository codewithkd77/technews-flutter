import 'package:equatable/equatable.dart';
import '../../models/news_article.dart';

/// Represents the different states of the news detail screen
abstract class NewsDetailState extends Equatable {
  const NewsDetailState();

  @override
  List<Object> get props => [];
}

/// Initial state when the news detail screen is first created
class NewsDetailInitial extends NewsDetailState {
  const NewsDetailInitial();
}

/// State when the news detail screen is loading data
class NewsDetailLoading extends NewsDetailState {
  const NewsDetailLoading();
}

/// State when the news detail screen has loaded successfully
class NewsDetailLoaded extends NewsDetailState {
  final NewsArticle article;
  final bool isBookmarked;
  final bool isAnimationCompleted;

  const NewsDetailLoaded({
    required this.article,
    required this.isBookmarked,
    this.isAnimationCompleted = false,
  });

  /// Creates a copy of the loaded state with updated values
  NewsDetailLoaded copyWith({
    NewsArticle? article,
    bool? isBookmarked,
    bool? isAnimationCompleted,
  }) {
    return NewsDetailLoaded(
      article: article ?? this.article,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isAnimationCompleted: isAnimationCompleted ?? this.isAnimationCompleted,
    );
  }

  @override
  List<Object> get props => [article, isBookmarked, isAnimationCompleted];
}

/// State when there's an error in the news detail screen
class NewsDetailError extends NewsDetailState {
  final String message;

  const NewsDetailError(this.message);

  @override
  List<Object> get props => [message];
}

/// State when sharing is in progress
class NewsDetailSharing extends NewsDetailState {
  const NewsDetailSharing();
}

/// State when sharing is completed
class NewsDetailShareCompleted extends NewsDetailState {
  final bool success;
  final String? message;

  const NewsDetailShareCompleted({
    required this.success,
    this.message,
  });

  @override
  List<Object> get props => [success, message ?? ''];
}
