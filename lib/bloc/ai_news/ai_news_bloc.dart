import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../core/errors/exceptions.dart';
import 'ai_news_event.dart';
import 'ai_news_state.dart';

/// BLoC responsible for managing AI news
/// Handles fetching and refreshing of AI news articles
class AiNewsBloc extends Bloc<AiNewsEvent, AiNewsState> {
  final NewsRepository _newsRepository;

  AiNewsBloc({required NewsRepository newsRepository})
      : _newsRepository = newsRepository,
        super(const AiNewsInitial()) {
    // Register event handlers
    on<AiNewsFetched>(_onAiNewsFetched);
    on<AiNewsRefreshed>(_onAiNewsRefreshed);
  }

  /// Handles AI news fetch events
  /// Loads AI news articles from repository
  Future<void> _onAiNewsFetched(
      AiNewsFetched event, Emitter<AiNewsState> emit) async {
    emit(const AiNewsLoading());

    try {
      final articles = await _newsRepository.fetchAiNews();
      emit(AiNewsLoaded(articles: articles));
    } on NetworkException catch (e) {
      emit(AiNewsError('Network error: ${e.message}'));
    } on ApiException catch (e) {
      emit(AiNewsError('API error: ${e.message}'));
    } catch (error) {
      emit(AiNewsError('Failed to load AI news: ${error.toString()}'));
    }
  }

  /// Handles AI news refresh events
  /// Similar to fetch but used for pull-to-refresh functionality
  Future<void> _onAiNewsRefreshed(
      AiNewsRefreshed event, Emitter<AiNewsState> emit) async {
    try {
      // Don't emit loading state for refresh to avoid UI flickering
      final articles = await _newsRepository.fetchAiNews();
      emit(AiNewsLoaded(articles: articles));
    } on NetworkException catch (e) {
      // If refresh fails and we have existing data, keep the current state
      if (state is AiNewsLoaded) return;
      emit(AiNewsError('Network error: ${e.message}'));
    } on ApiException catch (e) {
      if (state is AiNewsLoaded) return;
      emit(AiNewsError('API error: ${e.message}'));
    } catch (error) {
      // If refresh fails and we have existing data, keep the current state
      if (state is AiNewsLoaded) {
        // Could emit a snackbar event here in a real app
        return;
      }
      emit(AiNewsError('Failed to refresh AI news: ${error.toString()}'));
    }
  }
}
