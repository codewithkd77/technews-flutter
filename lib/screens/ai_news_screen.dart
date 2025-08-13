import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/ai_news/ai_news_bloc.dart';
import '../bloc/ai_news/ai_news_event.dart';
import '../bloc/ai_news/ai_news_state.dart';

class MyNewsScreen extends StatefulWidget {
  @override
  _MyNewsScreenState createState() => _MyNewsScreenState();
}

class _MyNewsScreenState extends State<MyNewsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize AI news loading when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AiNewsBloc>().add(const AiNewsFetched());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiNewsBloc, AiNewsState>(
      builder: (context, state) {
        if (state is AiNewsLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is AiNewsError) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<AiNewsBloc>().add(const AiNewsRefreshed());
            },
            child: ListView(
              children: [
                Center(child: Text("Error loading AI news: ${state.message}")),
              ],
            ),
          );
        } else if (state is AiNewsLoaded) {
          if (state.articles.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<AiNewsBloc>().add(const AiNewsRefreshed());
              },
              child: ListView(
                children: [
                  Center(child: Text("No AI news available")),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AiNewsBloc>().add(const AiNewsRefreshed());
            },
            child: ListView.builder(
              itemCount: state.articles.length,
              itemBuilder: (context, index) {
                final news = state.articles[index];

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            news.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            news.source ?? "Unknown Source",
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 5),
                          _buildClickableUrl(news.url ?? ""),
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
            context.read<AiNewsBloc>().add(const AiNewsRefreshed());
          },
          child: ListView(
            children: [
              Center(child: Text("No AI news available")),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchURL(String url) async {
    if (url.isEmpty) return;

    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      )) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print("Error launching URL: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Could not open the link. Please try again later.")),
        );
      }
    }
  }

  Widget _buildClickableUrl(String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Text(
        url,
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
          fontSize: 14,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}
