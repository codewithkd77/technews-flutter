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

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(MyApp(sharedPreferences: sharedPreferences));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const MyApp({Key? key, required this.sharedPreferences}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final remoteDataSource =
        NewsRemoteDataSourceImpl(httpClient: http.Client());
    final localDataSource =
        NewsLocalDataSourceImpl(sharedPreferences: sharedPreferences);

    final newsRepository = NewsRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationBloc>(
          create: (context) => NavigationBloc(),
        ),
        BlocProvider<NewsBloc>(
          create: (context) => NewsBloc(newsRepository: newsRepository),
        ),
        BlocProvider<AiNewsBloc>(
          create: (context) => AiNewsBloc(newsRepository: newsRepository),
        ),
        BlocProvider<SavedNewsBloc>(
          create: (context) => SavedNewsBloc(newsRepository: newsRepository),
        ),
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
