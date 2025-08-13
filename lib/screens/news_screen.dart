import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'news_detail_screen.dart';
import 'ai_news_screen.dart';
import 'saved_news_screen.dart';
import '../bloc/navigation/navigation_bloc.dart';
import '../bloc/navigation/navigation_event.dart';
import '../bloc/navigation/navigation_state.dart';
import '../bloc/news/news_bloc.dart';
import '../bloc/news/news_event.dart';
import '../bloc/news/news_state.dart';

class NewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, navigationState) {
        final TextEditingController searchController = TextEditingController();

        final List<Widget> screens = [
          NewsTab(),
          MyNewsScreen(),
          SavedNewsScreen(),
        ];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF1E1E1E),
            title: navigationState.isSearching
                ? TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search news...",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.white70),
                    ),
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  )
                : Row(
                    children: [
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.bolt,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Tech",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        "Buzz",
                        style: TextStyle(
                          color: Color(0xFF64FFDA),
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
            actions: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: Icon(
                    navigationState.isSearching ? Icons.close : Icons.search,
                    key: ValueKey<bool>(navigationState.isSearching),
                    color: Colors.white,
                  ),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return RotationTransition(
                      turns: animation,
                      child: ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
                    );
                  },
                ),
                onPressed: () {
                  context.read<NavigationBloc>().add(const SearchToggled());
                  if (!navigationState.isSearching) {
                    searchController.clear();
                  }
                },
              ),
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              ),
            ],
          ),
          endDrawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, User!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'user@example.com',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.privacy_tip, color: Colors.black),
                  title: Text('Privacy Policy'),
                  onTap: () {
                    // Handle Privacy Policy tap
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.contact_mail, color: Colors.black),
                  title: Text('Contact Us'),
                  onTap: () {
                    // Handle Contact Us tap
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.info, color: Colors.black),
                  title: Text('About Us'),
                  onTap: () {
                    // Handle About Us tap
                  },
                ),
              ],
            ),
          ),
          body: IndexedStack(
            index: navigationState.selectedIndex,
            children: screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: navigationState.selectedIndex,
            onTap: (index) {
              context.read<NavigationBloc>().add(TabChanged(index));
            },
            backgroundColor: Colors.black,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.public),
                activeIcon: Icon(Icons.public, color: Color(0xFF64FFDA)),
                label: "All News",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.psychology),
                activeIcon: Icon(Icons.psychology, color: Color(0xFF64FFDA)),
                label: "AI News",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_border),
                activeIcon: Icon(Icons.bookmark, color: Color(0xFF64FFDA)),
                label: "Saved",
              ),
            ],
          ),
        );
      },
    );
  }
}

class NewsTab extends StatefulWidget {
  @override
  _NewsTabState createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  @override
  void initState() {
    super.initState();
    // Initialize news loading when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NewsBloc>().add(const NewsFetched());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsBloc, NewsState>(
      builder: (context, state) {
        if (state is NewsLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is NewsError) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<NewsBloc>().add(const NewsRefreshed());
            },
            child: ListView(
              children: [
                Center(child: Text("Error loading news: ${state.message}")),
              ],
            ),
          );
        } else if (state is NewsLoaded) {
          if (state.articles.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<NewsBloc>().add(const NewsRefreshed());
              },
              child: ListView(
                children: [
                  Center(child: Text("No news available")),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<NewsBloc>().add(const NewsRefreshed());
            },
            child: ListView.builder(
              itemCount: state.articles.length,
              itemBuilder: (context, index) {
                final news = state.articles[index];
                final isBookmarked = state.isBookmarked(news);

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
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
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
                                    SizedBox(width: 12),
                                    IconButton(
                                      icon: Icon(
                                        isBookmarked
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color: isBookmarked
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                      onPressed: () {
                                        context
                                            .read<NewsBloc>()
                                            .add(NewsBookmarkToggled(news));
                                      },
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
            context.read<NewsBloc>().add(const NewsRefreshed());
          },
          child: ListView(
            children: [
              Center(child: Text("No news available")),
            ],
          ),
        );
      },
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
