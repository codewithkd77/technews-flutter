import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../core/errors/exceptions.dart';
import 'saved_news_event.dart';
import 'saved_news_state.dart';

class SavedNewsBloc extends Bloc<SavedNewsEvent, SavedNewsState> {
  final NewsRepository _newsRepository;

  SavedNewsBloc({required NewsRepository newsRepository})
      : _newsRepository = newsRepository,
        super(const SavedNewsInitial()) {
    on<SavedNewsLoaded>(_onSavedNewsLoaded);
    on<SavedNewsRefreshed>(_onSavedNewsRefreshed);
    on<SavedNewsRemoved>(_onSavedNewsRemoved);
  }

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

  Future<void> _onSavedNewsRefreshed(
      SavedNewsRefreshed event, Emitter<SavedNewsState> emit) async {
    try {
      final savedArticles = await _newsRepository.loadBookmarkedNews();
      emit(SavedNewsLoadSuccess(savedArticles: savedArticles));
    } catch (error) {
      if (state is SavedNewsLoadSuccess) {
        return;
      }
      emit(SavedNewsError('Failed to refresh saved news: ${error.toString()}'));
    }
  }

  Future<void> _onSavedNewsRemoved(
      SavedNewsRemoved event, Emitter<SavedNewsState> emit) async {
    final currentState = state;
    if (currentState is! SavedNewsLoadSuccess) return;

    try {
      final updatedSavedArticles =
          await _newsRepository.removeFromBookmarks(event.article);

      emit(currentState.copyWith(savedArticles: updatedSavedArticles));
    } on CacheException catch (e) {
      emit(SavedNewsError('Storage error: ${e.message}'));
    } catch (error) {
      emit(SavedNewsError('Failed to remove saved news: ${error.toString()}'));
    }
  }
}
