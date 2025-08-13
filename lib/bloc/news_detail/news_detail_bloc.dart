import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../core/errors/exceptions.dart';
import '../../models/news_article.dart';
import 'news_detail_event.dart';
import 'news_detail_state.dart';

/// BLoC responsible for managing news detail screen functionality
/// Handles bookmark operations, sharing, and URL launching
class NewsDetailBloc extends Bloc<NewsDetailEvent, NewsDetailState> {
  final NewsRepository _newsRepository;
  NewsArticle? _currentArticle;

  NewsDetailBloc({required NewsRepository newsRepository})
      : _newsRepository = newsRepository,
        super(const NewsDetailInitial()) {
    // Register event handlers
    on<NewsDetailInitialized>(_onNewsDetailInitialized);
    on<NewsDetailBookmarkToggled>(_onNewsDetailBookmarkToggled);
    on<NewsDetailShared>(_onNewsDetailShared);
    on<NewsDetailUrlOpened>(_onNewsDetailUrlOpened);
  }

  /// Handles news detail initialization
  /// Loads the article and checks if it's bookmarked
  Future<void> _onNewsDetailInitialized(
      NewsDetailInitialized event, Emitter<NewsDetailState> emit) async {
    emit(const NewsDetailLoading());

    try {
      _currentArticle = event.article;
      final isBookmarked =
          await _newsRepository.isNewsBookmarked(event.article);

      emit(NewsDetailLoaded(
        article: event.article,
        isBookmarked: isBookmarked,
      ));

      // Simulate animation completion after a delay
      await Future.delayed(const Duration(milliseconds: 800));

      if (state is NewsDetailLoaded) {
        final currentState = state as NewsDetailLoaded;
        emit(currentState.copyWith(isAnimationCompleted: true));
      }
    } catch (error) {
      emit(NewsDetailError('Failed to load news detail: ${error.toString()}'));
    }
  }

  /// Handles bookmark toggle
  /// Adds or removes the article from bookmarks
  Future<void> _onNewsDetailBookmarkToggled(
      NewsDetailBookmarkToggled event, Emitter<NewsDetailState> emit) async {
    final currentState = state;
    if (currentState is! NewsDetailLoaded || _currentArticle == null) return;

    try {
      final List<NewsArticle> updatedBookmarks;

      if (currentState.isBookmarked) {
        // Remove from bookmarks
        updatedBookmarks =
            await _newsRepository.removeFromBookmarks(_currentArticle!);
      } else {
        // Add to bookmarks
        updatedBookmarks =
            await _newsRepository.addToBookmarks(_currentArticle!);
      }

      // Check if article is still bookmarked after the operation
      final isBookmarked = updatedBookmarks
          .any((bookmarked) => bookmarked.title == _currentArticle!.title);

      emit(currentState.copyWith(isBookmarked: isBookmarked));
    } on CacheException catch (e) {
      emit(NewsDetailError('Bookmark error: ${e.message}'));
    } catch (error) {
      emit(NewsDetailError('Failed to update bookmark: ${error.toString()}'));
    }
  }

  /// Handles news sharing
  /// Shares the article with text and optionally image
  Future<void> _onNewsDetailShared(
      NewsDetailShared event, Emitter<NewsDetailState> emit) async {
    final currentState = state;
    if (currentState is! NewsDetailLoaded || _currentArticle == null) return;

    emit(const NewsDetailSharing());

    try {
      final article = _currentArticle!;
      String title = article.title;
      String description =
          article.description ?? 'Stay updated with the latest tech news!';
      String url = article.url ?? '';
      String imageUrl = article.imageUrl ?? '';

      String shareText = "$title\n\n$description";
      if (url.isNotEmpty) {
        shareText += "\nRead more: $url";
      }
      shareText += "\n\n📲 Download TechBuzz for more such news!";

      if (imageUrl.isNotEmpty) {
        try {
          // Download the image and store it locally
          final response = await http.get(Uri.parse(imageUrl));
          final directory = await getTemporaryDirectory();
          final filePath = "${directory.path}/news_image.jpg";
          File imageFile = File(filePath);
          await imageFile.writeAsBytes(response.bodyBytes);

          // Share the image with text
          await Share.shareXFiles([XFile(filePath)], text: shareText);
        } catch (imageError) {
          // If image sharing fails, fallback to text only
          await Share.share(shareText);
        }
      } else {
        await Share.share(shareText);
      }

      emit(const NewsDetailShareCompleted(success: true));

      // Return to loaded state after sharing
      await Future.delayed(const Duration(milliseconds: 500));
      emit(currentState);
    } catch (error) {
      emit(NewsDetailShareCompleted(
        success: false,
        message: 'Failed to share: ${error.toString()}',
      ));

      // Return to loaded state after error
      await Future.delayed(const Duration(milliseconds: 2000));
      emit(currentState);
    }
  }

  /// Handles URL opening
  /// Launches the article URL in external browser
  Future<void> _onNewsDetailUrlOpened(
      NewsDetailUrlOpened event, Emitter<NewsDetailState> emit) async {
    try {
      final Uri uri = Uri.parse(event.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch ${event.url}');
      }
    } catch (error) {
      emit(NewsDetailError('Failed to open URL: ${error.toString()}'));

      // Return to previous state after error
      await Future.delayed(const Duration(milliseconds: 2000));
      if (_currentArticle != null) {
        final isBookmarked =
            await _newsRepository.isNewsBookmarked(_currentArticle!);
        emit(NewsDetailLoaded(
          article: _currentArticle!,
          isBookmarked: isBookmarked,
          isAnimationCompleted: true,
        ));
      }
    }
  }
}
