import 'package:equatable/equatable.dart';
import '../../models/news_article.dart';

/// Abstract base class for all news-related events
abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object> get props => [];
}

/// Event to fetch fresh news from the API
class NewsFetched extends NewsEvent {
  const NewsFetched();
}

/// Event to refresh news by pulling latest data
class NewsRefreshed extends NewsEvent {
  const NewsRefreshed();
}

/// Event to toggle bookmark status of a news article
class NewsBookmarkToggled extends NewsEvent {
  final NewsArticle article;

  const NewsBookmarkToggled(this.article);

  @override
  List<Object> get props => [article];
}
