import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../core/errors/exceptions.dart';
import 'saved_news_event.dart';
import 'saved_news_state.dart';

/// BLoC responsible for managing saved/bookmarked news
/// Handles loading, refreshing, and removing saved news articles
class SavedNewsBloc extends Bloc<SavedNewsEvent, SavedNewsState> {
  final NewsRepository _newsRepository;

  SavedNewsBloc({required NewsRepository newsRepository})
      : _newsRepository = newsRepository,
        super(const SavedNewsInitial()) {
    // Register event handlers
    on<SavedNewsLoaded>(_onSavedNewsLoaded);
    on<SavedNewsRefreshed>(_onSavedNewsRefreshed);
    on<SavedNewsRemoved>(_onSavedNewsRemoved);
  }

  /// Handles saved news load events
  /// Loads bookmarked articles from local storage
  Future<void> _onSavedNewsLoaded(
      SavedNewsLoaded event, Emitter<SavedNewsState> emit) async {
    emit(const SavedNewsLoading());

    try {
      final savedArticles = await _newsRepository.loadBookmarkedNews();
      emit(SavedNewsLoadSuccess(savedArticles: savedArticles));
    } on CacheException catch (e) {
      emit(SavedNewsError('Storage error: ${e.message}'));
    } catch (error) {
      emit(SavedNewsError('Failed to load saved news: ${error.toString()}'));
    }
  }

  /// Handles saved news refresh events
  /// Reloads bookmarked articles from local storage
  Future<void> _onSavedNewsRefreshed(
      SavedNewsRefreshed event, Emitter<SavedNewsState> emit) async {
    try {
      // Don't emit loading state for refresh to avoid UI flickering
      final savedArticles = await _newsRepository.loadBookmarkedNews();
      emit(SavedNewsLoadSuccess(savedArticles: savedArticles));
    } catch (error) {
      // If refresh fails and we have existing data, keep the current state
      if (state is SavedNewsLoadSuccess) {
        // Could emit a snackbar event here in a real app
        return;
      }
      emit(SavedNewsError('Failed to refresh saved news: ${error.toString()}'));
    }
  }

  /// Handles saved news removal events
  /// Removes a specific article from bookmarks and updates the state
  Future<void> _onSavedNewsRemoved(
      SavedNewsRemoved event, Emitter<SavedNewsState> emit) async {
    final currentState = state;
    if (currentState is! SavedNewsLoadSuccess) return;

    try {
      // Remove from repository
      final updatedSavedArticles =
          await _newsRepository.removeFromBookmarks(event.article);

      // Emit updated state
      emit(currentState.copyWith(savedArticles: updatedSavedArticles));
    } on CacheException catch (e) {
      emit(SavedNewsError('Storage error: ${e.message}'));
    } catch (error) {
      emit(SavedNewsError('Failed to remove saved news: ${error.toString()}'));
    }
  }
}
