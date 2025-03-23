import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

class NewsDetailScreen extends StatefulWidget {
  final Map<String, dynamic> news;

  NewsDetailScreen({required this.news});

  @override
  _NewsDetailScreenState createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen>
    with SingleTickerProviderStateMixin {
  bool isBookmarked = false;
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
    checkIfBookmarked();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void checkIfBookmarked() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedBookmarks = prefs.getString('bookmarked_news');

    if (savedBookmarks != null) {
      List<dynamic> bookmarkedList = jsonDecode(savedBookmarks);
      setState(() {
        isBookmarked =
            bookmarkedList.any((item) => item['title'] == widget.news['title']);
      });
    }
  }

  void toggleBookmark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedBookmarks = prefs.getString('bookmarked_news');
    List<dynamic> savedNewsList =
        savedBookmarks != null ? jsonDecode(savedBookmarks) : [];

    String newsJson = jsonEncode(widget.news);

    setState(() {
      if (isBookmarked) {
        savedNewsList.removeWhere((item) => jsonEncode(item) == newsJson);
      } else {
        savedNewsList.add(widget.news);
      }
      isBookmarked = !isBookmarked;
    });

    await prefs.setString('bookmarked_news', jsonEncode(savedNewsList));
    print("Updated bookmarks: $savedNewsList"); // Debugging print
  }

  void shareNews() async {
    try {
      String title = widget.news['title'] ?? 'Tech News';
      String description = widget.news['description'] ??
          'Stay updated with the latest tech news!';
      String url = widget.news['url'] ?? ''; // Ensure URL exists
      String imageUrl = widget.news['imageUrl'] ?? '';

      String shareText = "$title\n\n$description";
      if (url.isNotEmpty) {
        shareText += "\nRead more: $url";
      }
      shareText += "\n\n📲 Download TechBuzz for more such news!";

      if (imageUrl.isNotEmpty) {
        // Download the image and store it locally
        final response = await http.get(Uri.parse(imageUrl));
        final directory = await getTemporaryDirectory();
        final filePath = "${directory.path}/news_image.jpg";
        File imageFile = File(filePath);
        await imageFile.writeAsBytes(response.bodyBytes);

        // Share the image with text
        await Share.shareXFiles([XFile(filePath)], text: shareText);
      } else {
        await Share.share(shareText);
      }
    } catch (e) {
      print("Error sharing news: $e"); // Debugging print
    }
  }

  Future<void> _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
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

  Widget _buildDescription(String text) {
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
          recognizer: TapGestureRecognizer()..onTap = () => _launchURL(url),
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
    String description = widget.news['description']?.isNotEmpty == true
        ? widget.news['description']
        : widget.news['content']?.isNotEmpty == true
            ? widget.news['content']
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
              transitionBuilder: (Widget child, Animation<double> animation) {
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
            onPressed: toggleBookmark,
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: shareNews,
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
                    tag: 'newsImage${widget.news['title']}',
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
                          image: NetworkImage(widget.news['imageUrl'] ?? ''),
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
                        if (widget.news['source'] != null &&
                            widget.news['source'].toString().isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color(0xFF1E88E5).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.news['source'],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        Spacer(),
                        if (widget.news['createdAt'] != null)
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
                                  getTimeAgo(widget.news['createdAt']),
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
                      widget.news['title'] ?? "",
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
                    _buildDescription(description),
                    SizedBox(height: 20),
                    if (widget.news['url'] != null)
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
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
                          onPressed: () => _launchURL(widget.news['url']),
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
}
