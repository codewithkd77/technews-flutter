import 'package:equatable/equatable.dart';
import '../../models/news_article.dart';

/// Abstract base class for all news detail events
abstract class NewsDetailEvent extends Equatable {
  const NewsDetailEvent();

  @override
  List<Object> get props => [];
}

/// Event to initialize the news detail screen with an article
class NewsDetailInitialized extends NewsDetailEvent {
  final NewsArticle article;

  const NewsDetailInitialized(this.article);

  @override
  List<Object> get props => [article];
}

/// Event to toggle bookmark status of the current article
class NewsDetailBookmarkToggled extends NewsDetailEvent {
  const NewsDetailBookmarkToggled();
}

/// Event to share the current news article
class NewsDetailShared extends NewsDetailEvent {
  const NewsDetailShared();
}

/// Event to open the full article URL
class NewsDetailUrlOpened extends NewsDetailEvent {
  final String url;

  const NewsDetailUrlOpened(this.url);

  @override
  List<Object> get props => [url];
}
