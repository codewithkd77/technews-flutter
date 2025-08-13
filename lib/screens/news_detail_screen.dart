import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/gestures.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/news_article.dart';
import '../bloc/news_detail/news_detail_bloc.dart';
import '../bloc/news_detail/news_detail_event.dart';
import '../bloc/news_detail/news_detail_state.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsArticle article;

  NewsDetailScreen({required this.article});

  @override
  _NewsDetailScreenState createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();

    // Initialize the news detail BLoC with the article
    context.read<NewsDetailBloc>().add(NewsDetailInitialized(widget.article));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String getTimeAgo(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return "";
    try {
      DateTime parsedDate = DateTime.parse(createdAt).toLocal();
      return timeago.format(parsedDate, locale: 'en');
    } catch (e) {
      return "";
    }
  }

  Widget _buildDescription(String text, NewsDetailBloc bloc) {
    final RegExp urlRegExp = RegExp(
      r"(https?:\/\/|ftp:\/\/|file:\/\/|mailto:|tel:|www\.)[^\s]+",
      caseSensitive: false,
      multiLine: true,
    );

    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    urlRegExp.allMatches(text).forEach((match) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }

      String url = match.group(0)!;
      if (!url.startsWith(RegExp(r'https?:|ftp:|file:|mailto:|tel:'))) {
        url = 'https://$url';
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: TextStyle(
              color: Color(0xFF1E88E5),
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w500),
          recognizer: TapGestureRecognizer()
            ..onTap = () => bloc.add(NewsDetailUrlOpened(url)),
        ),
      );

      lastMatchEnd = match.end;
    });

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 17,
          color: Color(0xFF424242),
          height: 1.6,
          letterSpacing: 0.2,
        ),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsDetailBloc, NewsDetailState>(
      builder: (context, state) {
        if (state is NewsDetailLoading || state is NewsDetailInitial) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
              ),
            ),
          );
        }

        if (state is NewsDetailError) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Color(0xFF1E88E5),
              title: Text('Error'),
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is NewsDetailSharing) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Sharing article...',
                    style: TextStyle(fontSize: 16, color: Color(0xFF424242)),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is NewsDetailShareCompleted) {
          // Show snackbar for share completion
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.success
                      ? 'Article shared successfully!'
                      : state.message ?? 'Failed to share article',
                ),
                backgroundColor: state.success ? Colors.green : Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          });
        }

        if (state is NewsDetailLoaded) {
          final article = state.article;
          final isBookmarked = state.isBookmarked;
          final bloc = context.read<NewsDetailBloc>();

          String description = article.description?.isNotEmpty == true
              ? article.description!
              : article.content?.isNotEmpty == true
                  ? article.content!
                  : "No content available";

          return Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      key: ValueKey<bool>(isBookmarked),
                      color: isBookmarked ? Color(0xFF64FFDA) : Colors.white,
                    ),
                  ),
                  onPressed: () => bloc.add(NewsDetailBookmarkToggled()),
                ),
                IconButton(
                  icon: Icon(Icons.share, color: Colors.white),
                  onPressed: () => bloc.add(NewsDetailShared()),
                ),
              ],
            ),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        // Image at the top - position preserved as requested
                        Hero(
                          tag: 'newsImage${article.title}',
                          child: Container(
                            height: 300,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              image: DecorationImage(
                                image: NetworkImage(article.imageUrl ?? ''),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {},
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Source and time on top of the image
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Row(
                            children: [
                              if (article.source != null &&
                                  article.source!.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1E88E5).withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    article.source!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              Spacer(),
                              if (article.createdAt != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        getTimeAgo(article.createdAt),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                              height: 1.4,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            height: 4,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Color(0xFF64FFDA),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(height: 24),
                          _buildDescription(description, bloc),
                          SizedBox(height: 20),
                          if (article.url != null && article.url!.isNotEmpty)
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF1E88E5),
                                    Color(0xFF0D47A1)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF1E88E5).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () =>
                                    bloc.add(NewsDetailUrlOpened(article.url!)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.open_in_new,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Read Full Article',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Fallback for any unexpected state
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Text('Something went wrong'),
          ),
        );
      },
    );
  }
}
