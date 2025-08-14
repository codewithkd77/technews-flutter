import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../core/errors/exceptions.dart';
import '../../models/news_article.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository _newsRepository;

  NewsBloc({required NewsRepository newsRepository})
      : _newsRepository = newsRepository,
        super(const NewsInitial()) {
    on<NewsFetched>(_onNewsFetched);
    on<NewsRefreshed>(_onNewsRefreshed);
    on<NewsBookmarkToggled>(_onNewsBookmarkToggled);
  }

  Future<void> _onNewsFetched(
      NewsFetched event, Emitter<NewsState> emit) async {
    emit(const NewsLoading());

    try {
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

  Future<void> _onNewsRefreshed(
      NewsRefreshed event, Emitter<NewsState> emit) async {
    try {
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
      if (state is NewsLoaded) {
        return;
      }
      emit(NewsError('Network error: ${e.message}'));
    } on ApiException catch (e) {
      if (state is NewsLoaded) return;
      emit(NewsError('API error: ${e.message}'));
    } catch (error) {
      if (state is NewsLoaded) {
        return;
      }
      emit(NewsError('Failed to refresh news: ${error.toString()}'));
    }
  }

  Future<void> _onNewsBookmarkToggled(
      NewsBookmarkToggled event, Emitter<NewsState> emit) async {
    final currentState = state;
    if (currentState is! NewsLoaded) return;

    try {
      final isCurrentlyBookmarked = currentState.isBookmarked(event.article);
      final List<NewsArticle> updatedBookmarks;

      if (isCurrentlyBookmarked) {
        updatedBookmarks =
            await _newsRepository.removeFromBookmarks(event.article);
      } else {
        updatedBookmarks = await _newsRepository.addToBookmarks(event.article);
      }

      emit(currentState.copyWith(bookmarkedArticles: updatedBookmarks));
    } on CacheException catch (e) {
      emit(NewsError('Bookmark error: ${e.message}'));
    } catch (error) {
      emit(NewsError('Failed to update bookmark: ${error.toString()}'));
    }
  }
}
