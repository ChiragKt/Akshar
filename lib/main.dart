import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const EbookReaderApp());
}

class EbookReaderApp extends StatelessWidget {
  const EbookReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akshar',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFFFF6584),
          tertiary: Color(0xFF4CAF50),
          surface: Color(0xFF242424),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF242424),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFF6584),
          foregroundColor: Colors.white,
        ),

        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF333333),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),

      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
