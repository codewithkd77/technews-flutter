import 'package:equatable/equatable.dart';
import '../../models/news_article.dart';

/// Represents the different states of saved news management
abstract class SavedNewsState extends Equatable {
  const SavedNewsState();

  @override
  List<Object> get props => [];
}

/// Initial state when the Saved News BLoC is first created
class SavedNewsInitial extends SavedNewsState {
  const SavedNewsInitial();
}

/// State when saved news is being loaded from local storage
class SavedNewsLoading extends SavedNewsState {
  const SavedNewsLoading();
}

/// State when saved news has been successfully loaded
class SavedNewsLoadSuccess extends SavedNewsState {
  final List<NewsArticle> savedArticles;

  const SavedNewsLoadSuccess({required this.savedArticles});

  /// Creates a copy of the loaded state with updated articles
  SavedNewsLoadSuccess copyWith({List<NewsArticle>? savedArticles}) {
    return SavedNewsLoadSuccess(
        savedArticles: savedArticles ?? this.savedArticles);
  }

  /// Checks if the saved news list is empty
  bool get isEmpty => savedArticles.isEmpty;

  @override
  List<Object> get props => [savedArticles];
}

/// State when there's an error loading saved news
class SavedNewsError extends SavedNewsState {
  final String message;

  const SavedNewsError(this.message);

  @override
  List<Object> get props => [message];
}
