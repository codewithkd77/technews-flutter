import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'screens/news_screen.dart';
import 'data/repositories/news_repository_impl.dart';
import 'data/datasources/news_remote_data_source.dart';
import 'data/datasources/news_local_data_source.dart';
import 'bloc/navigation/navigation_bloc.dart';
import 'bloc/news/news_bloc.dart';
import 'bloc/ai_news/ai_news_bloc.dart';
import 'bloc/saved_news/saved_news_bloc.dart';
import 'bloc/news_detail/news_detail_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(MyApp(sharedPreferences: sharedPreferences));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const MyApp({Key? key, required this.sharedPreferences}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create data sources
    final remoteDataSource =
        NewsRemoteDataSourceImpl(httpClient: http.Client());
    final localDataSource =
        NewsLocalDataSourceImpl(sharedPreferences: sharedPreferences);

    // Create repository instance with dependency injection
    final newsRepository = NewsRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );

    return MultiBlocProvider(
      providers: [
        // Navigation BLoC for handling bottom navigation and search
        BlocProvider<NavigationBloc>(
          create: (context) => NavigationBloc(),
        ),
        // News BLoC for handling general tech news
        BlocProvider<NewsBloc>(
          create: (context) => NewsBloc(newsRepository: newsRepository),
        ),
        // AI News BLoC for handling AI-specific news
        BlocProvider<AiNewsBloc>(
          create: (context) => AiNewsBloc(newsRepository: newsRepository),
        ),
        // Saved News BLoC for handling bookmarked articles
        BlocProvider<SavedNewsBloc>(
          create: (context) => SavedNewsBloc(newsRepository: newsRepository),
        ),
        // News Detail BLoC for handling article detail screen
        BlocProvider<NewsDetailBloc>(
          create: (context) => NewsDetailBloc(newsRepository: newsRepository),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tech News',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: NewsScreen(),
      ),
    );
  }
}
