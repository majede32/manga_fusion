import 'package:flutter/material.dart';
import 'main_screen.dart';

void main() {
  runApp(MangaFusionApp());
}

class MangaFusionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manga Fusion',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Color(0xFF121212),
        appBarTheme: AppBarTheme(color: Color(0xFF1E1E1E), elevation: 0),
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
