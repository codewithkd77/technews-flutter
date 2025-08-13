import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../core/errors/exceptions.dart';
import '../../models/news_article.dart';
import 'news_event.dart';
import 'news_state.dart';

/// BLoC responsible for managing general tech news
/// Handles fetching, refreshing, and bookmarking of news articles
class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository _newsRepository;

  NewsBloc({required NewsRepository newsRepository})
      : _newsRepository = newsRepository,
        super(const NewsInitial()) {
    // Register event handlers
    on<NewsFetched>(_onNewsFetched);
    on<NewsRefreshed>(_onNewsRefreshed);
    on<NewsBookmarkToggled>(_onNewsBookmarkToggled);
  }

  /// Handles news fetch events
  /// Loads news articles and bookmarked articles from repository
  Future<void> _onNewsFetched(
      NewsFetched event, Emitter<NewsState> emit) async {
    emit(const NewsLoading());

    try {
      // Fetch both news articles and bookmarked articles concurrently
      final results = await Future.wait([
        _newsRepository.fetchNews(),
        _newsRepository.loadBookmarkedNews(),
      ]);

      final articles = results[0];
      final bookmarkedArticles = results[1];

      emit(NewsLoaded(
        articles: articles,
        bookmarkedArticles: bookmarkedArticles,
      ));
    } on NetworkException catch (e) {
      emit(NewsError('Network error: ${e.message}'));
    } on ApiException catch (e) {
      emit(NewsError('API error: ${e.message}'));
    } on CacheException catch (e) {
      emit(NewsError('Storage error: ${e.message}'));
    } catch (error) {
      emit(NewsError('Failed to load news: ${error.toString()}'));
    }
  }

  /// Handles news refresh events
  /// Similar to fetch but used for pull-to-refresh functionality
  Future<void> _onNewsRefreshed(
      NewsRefreshed event, Emitter<NewsState> emit) async {
    try {
      // Don't emit loading state for refresh to avoid UI flickering
      final results = await Future.wait([
        _newsRepository.fetchNews(),
        _newsRepository.loadBookmarkedNews(),
      ]);

      final articles = results[0];
      final bookmarkedArticles = results[1];

      emit(NewsLoaded(
        articles: articles,
        bookmarkedArticles: bookmarkedArticles,
      ));
    } on NetworkException catch (e) {
      // If refresh fails and we have existing data, keep the current state
      if (state is NewsLoaded) {
        // Could emit a snackbar event here in a real app
        return;
      }
      emit(NewsError('Network error: ${e.message}'));
    } on ApiException catch (e) {
      if (state is NewsLoaded) return;
      emit(NewsError('API error: ${e.message}'));
    } catch (error) {
      // If refresh fails and we have existing data, keep the current state
      if (state is NewsLoaded) {
        // Could emit a snackbar event here in a real app
        return;
      }
      emit(NewsError('Failed to refresh news: ${error.toString()}'));
    }
  }

  /// Handles bookmark toggle events
  /// Adds or removes articles from bookmarks and updates the state
  Future<void> _onNewsBookmarkToggled(
      NewsBookmarkToggled event, Emitter<NewsState> emit) async {
    final currentState = state;
    if (currentState is! NewsLoaded) return;

    try {
      final isCurrentlyBookmarked = currentState.isBookmarked(event.article);
      final List<NewsArticle> updatedBookmarks;

      if (isCurrentlyBookmarked) {
        // Remove from bookmarks
        updatedBookmarks =
            await _newsRepository.removeFromBookmarks(event.article);
      } else {
        // Add to bookmarks
        updatedBookmarks = await _newsRepository.addToBookmarks(event.article);
      }

      // Emit updated state with new bookmark list
      emit(currentState.copyWith(bookmarkedArticles: updatedBookmarks));
    } on CacheException catch (e) {
      emit(NewsError('Bookmark error: ${e.message}'));
    } catch (error) {
      // In case of error, emit error state or handle gracefully
      emit(NewsError('Failed to update bookmark: ${error.toString()}'));
    }
  }
}
