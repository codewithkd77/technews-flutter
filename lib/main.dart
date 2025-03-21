import 'package:flutter/material.dart';
import 'screens/news_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tech News',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NewsScreen(),
    );
  }
}
