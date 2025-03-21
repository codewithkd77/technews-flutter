import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'news_detail_screen.dart';

class SavedNewsScreen extends StatefulWidget {
  @override
  _SavedNewsScreenState createState() => _SavedNewsScreenState();
}

class _SavedNewsScreenState extends State<SavedNewsScreen> {
  List<dynamic> savedNews = [];

  @override
  void initState() {
    super.initState();
    loadSavedNews();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadSavedNews(); // Reload news when the screen is revisited
  }

  @override
  void reassemble() {
    super.reassemble();
    loadSavedNews(); // Refresh when coming back from background
  }

  Future<void> loadSavedNews() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedBookmarks = prefs.getString('bookmarked_news');

    if (savedBookmarks != null) {
      setState(() {
        savedNews = List.from(jsonDecode(savedBookmarks));
      });
      print("Loaded saved news: \$savedNews"); // Debugging print
    } else {
      print("No saved news found in storage.");
    }
  }

  void removeBookmark(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedNews.removeAt(index);
    await prefs.setString('bookmarked_news', jsonEncode(savedNews));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Saved News")),
      body: RefreshIndicator(
        onRefresh: loadSavedNews,
        child: savedNews.isEmpty
            ? Center(child: Text("No saved news found"))
            : ListView.builder(
                itemCount: savedNews.length,
                itemBuilder: (context, index) {
                  final news = savedNews[index];

                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsDetailScreen(news: news),
                        ),
                      ).then((_) => loadSavedNews()); // Refresh after returning
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        news['imageUrl'] ?? '',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.image_not_supported, size: 70),
                      ),
                    ),
                    title: Text(news['title'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text(news['category'] ?? "General",
                        style: TextStyle(color: Colors.grey)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeBookmark(index),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
