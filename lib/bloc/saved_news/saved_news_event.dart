import 'package:equatable/equatable.dart';
import '../../models/news_article.dart';

/// Abstract base class for all saved news-related events
abstract class SavedNewsEvent extends Equatable {
  const SavedNewsEvent();

  @override
  List<Object> get props => [];
}

/// Event to load saved/bookmarked news from local storage
class SavedNewsLoaded extends SavedNewsEvent {
  const SavedNewsLoaded();
}

/// Event to refresh saved news from local storage
class SavedNewsRefreshed extends SavedNewsEvent {
  const SavedNewsRefreshed();
}

/// Event to remove a specific article from saved news
class SavedNewsRemoved extends SavedNewsEvent {
  final NewsArticle article;

  const SavedNewsRemoved(this.article);

  @override
  List<Object> get props => [article];
}
