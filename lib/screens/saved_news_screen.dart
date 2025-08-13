import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'news_detail_screen.dart';
import '../bloc/saved_news/saved_news_bloc.dart';
import '../bloc/saved_news/saved_news_event.dart';
import '../bloc/saved_news/saved_news_state.dart';

class SavedNewsScreen extends StatefulWidget {
  @override
  _SavedNewsScreenState createState() => _SavedNewsScreenState();
}

class _SavedNewsScreenState extends State<SavedNewsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize saved news loading when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SavedNewsBloc>().add(const SavedNewsLoaded());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SavedNewsBloc, SavedNewsState>(
        builder: (context, state) {
          if (state is SavedNewsLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is SavedNewsError) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<SavedNewsBloc>().add(const SavedNewsRefreshed());
              },
              child: ListView(
                children: [
                  Center(
                      child:
                          Text("Error loading saved news: ${state.message}")),
                ],
              ),
            );
          } else if (state is SavedNewsLoadSuccess) {
            if (state.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<SavedNewsBloc>().add(const SavedNewsRefreshed());
                },
                child: ListView(
                  children: [
                    Center(child: Text("No saved news available")),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<SavedNewsBloc>().add(const SavedNewsRefreshed());
              },
              child: ListView.builder(
                itemCount: state.savedArticles.length,
                itemBuilder: (context, index) {
                  final news = state.savedArticles[index];

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NewsDetailScreen(article: news),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16)),
                              child: Image.network(
                                news.imageUrl ?? '',
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 180,
                                  color: Colors.grey[200],
                                  child: Icon(Icons.image_not_supported,
                                      size: 50, color: Colors.grey),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    news.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    news.description ??
                                        'No description available',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Text(
                                        news.source ?? 'Unknown',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(Icons.access_time,
                                          size: 16, color: Colors.grey),
                                      SizedBox(width: 4),
                                      Text(
                                        _getTimeAgo(news.createdAt),
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<SavedNewsBloc>().add(const SavedNewsRefreshed());
            },
            child: ListView(
              children: [
                Center(child: Text("No saved news available")),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getTimeAgo(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return "Unknown time";
    try {
      DateTime parsedDate = DateTime.parse(createdAt).toLocal();
      return timeago.format(parsedDate, locale: 'en');
    } catch (e) {
      return "Unknown time";
    }
  }
}
