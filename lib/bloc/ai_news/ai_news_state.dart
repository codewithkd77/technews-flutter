import 'package:equatable/equatable.dart';
import '../../models/news_article.dart';

/// Represents the different states of AI news loading
abstract class AiNewsState extends Equatable {
  const AiNewsState();

  @override
  List<Object> get props => [];
}

/// Initial state when the AI News BLoC is first created
class AiNewsInitial extends AiNewsState {
  const AiNewsInitial();
}

/// State when AI news is being loaded from the API
class AiNewsLoading extends AiNewsState {
  const AiNewsLoading();
}

/// State when AI news has been successfully loaded
class AiNewsLoaded extends AiNewsState {
  final List<NewsArticle> articles;

  const AiNewsLoaded({required this.articles});

  /// Creates a copy of the loaded state with updated articles
  AiNewsLoaded copyWith({List<NewsArticle>? articles}) {
    return AiNewsLoaded(articles: articles ?? this.articles);
  }

  @override
  List<Object> get props => [articles];
}

/// State when there's an error loading AI news
class AiNewsError extends AiNewsState {
  final String message;

  const AiNewsError(this.message);

  @override
  List<Object> get props => [message];
}
