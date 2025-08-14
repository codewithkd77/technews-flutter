import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../core/errors/exceptions.dart';
import 'ai_news_event.dart';
import 'ai_news_state.dart';

class AiNewsBloc extends Bloc<AiNewsEvent, AiNewsState> {
  final NewsRepository _newsRepository;

  AiNewsBloc({required NewsRepository newsRepository})
      : _newsRepository = newsRepository,
        super(const AiNewsInitial()) {
    on<AiNewsFetched>(_onAiNewsFetched);
    on<AiNewsRefreshed>(_onAiNewsRefreshed);
  }

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

  Future<void> _onAiNewsRefreshed(
      AiNewsRefreshed event, Emitter<AiNewsState> emit) async {
    try {
      final articles = await _newsRepository.fetchAiNews();
      emit(AiNewsLoaded(articles: articles));
    } on NetworkException catch (e) {
      if (state is AiNewsLoaded) return;
      emit(AiNewsError('Network error: ${e.message}'));
    } on ApiException catch (e) {
      if (state is AiNewsLoaded) return;
      emit(AiNewsError('API error: ${e.message}'));
    } catch (error) {
      if (state is AiNewsLoaded) {
        return;
      }
      emit(AiNewsError('Failed to refresh AI news: ${error.toString()}'));
    }
  }
}
