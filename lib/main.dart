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
      color: Colors.white,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7C8CFF), // brighter
          secondary: Color(0xFFFF6B8B), // accent
          surface: Color(0xFF1C1C1E),
          background: Color(0xFF121212),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFFBFD1FF), // bright logo/title
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
          iconTheme: IconThemeData(color: Color(0xFFBFD1FF)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF7C8CFF),
          foregroundColor: Colors.black,
          elevation: 3,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF1F2937),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
