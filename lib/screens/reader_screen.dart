import 'package:akshar_final/models/books.dart';
import 'package:akshar_final/models/reading_settings.dart';
import 'package:akshar_final/services/book_services.dart';
import 'package:flutter/material.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;

  const ReaderScreen({super.key, required this.book});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final ReadingSettings _settings = ReadingSettings();
  bool _showSettings = false;
  final BookService _bookService = BookService();

  final List<Color> _backgroundColors = [
    const Color(0xFFFFFFFF), // White
    const Color(0xFFFFF8DC), // Cornsilk
    const Color(0xFFE8DCC0), // Sepia
    const Color(0xFF2C2C2C), // Dark
  ];

  @override
  void initState() {
    super.initState();
    _bookService.updateLastRead(widget.book.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _settings.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _settings.backgroundColor,
        iconTheme: IconThemeData(color: _settings.textColor),
        title: Text(
          widget.book.title,
          style: TextStyle(color: _settings.textColor, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: _settings.textColor),
            onPressed: () {
              setState(() {
                _showSettings = !_showSettings;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book.title,
                  style: TextStyle(
                    fontSize: _settings.fontSize + 6,
                    fontWeight: FontWeight.bold,
                    color: _settings.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'by ${widget.book.author}',
                  style: TextStyle(
                    fontSize: _settings.fontSize - 2,
                    fontStyle: FontStyle.italic,
                    color: _settings.textColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.book.content,
                  style: TextStyle(
                    fontSize: _settings.fontSize,
                    color: _settings.textColor,
                    height: 1.8,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          if (_showSettings)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SettingsPanel(
                settings: _settings,
                backgroundColors: _backgroundColors,
                onSettingsChanged: () {
                  setState(() {});
                },
              ),
            ),
        ],
      ),
    );
  }
}
