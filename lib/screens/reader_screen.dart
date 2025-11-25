import 'package:flutter/material.dart';
import 'package:akshar_final/models/books.dart';
import 'package:akshar_final/models/reading_settings.dart';
import 'package:akshar_final/services/book_services.dart';
import 'package:akshar_final/widgets/settings_panel.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;
  const ReaderScreen({super.key, required this.book});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final ReadingSettings _settings = ReadingSettings.shared;
  final BookService _bookService = BookService();
  final ScrollController _scroll = ScrollController();

  bool _showSettings = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients &&
          widget.book.bookmarkOffset > 0 &&
          widget.book.bookmarkOffset < _scroll.position.maxScrollExtent) {
        _scroll.jumpTo(widget.book.bookmarkOffset);
      }
    });

    _scroll.addListener(() {
      if (_scroll.hasClients) {
        widget.book.bookmarkOffset = _scroll.offset;
      }
    });

    _bookService.updateLastRead(widget.book.id);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  double get _progress {
    if (!_scroll.hasClients) return 0;
    final max = _scroll.position.maxScrollExtent;
    if (max == 0) return 0;
    return (_scroll.offset / max).clamp(0.0, 1.0);
  }

  void _cycleTheme() {
    final themes = ReadingSettings.themes;
    final currentIndex = themes.indexWhere(
      (c) => c.toARGB32() == _settings.backgroundColor.toARGB32(),
    );
    final next = themes[(currentIndex + 1) % themes.length];

    setState(() {
      _settings.backgroundColor = next;
      _settings.textColor =
          next.computeLuminance() < 0.5 ? Colors.white : Colors.black87;
    });
  }

  void _toggleBookmark() {
    setState(() {
      if (_scroll.hasClients) {
        widget.book.bookmarkOffset =
            widget.book.bookmarkOffset > 0 ? 0 : _scroll.offset;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.book.bookmarkOffset > 0
              ? "Bookmark saved"
              : "Bookmark removed",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _settings.backgroundColor.computeLuminance() < 0.3;

    return Scaffold(
      backgroundColor: _settings.backgroundColor,
      appBar: AppBar(
        backgroundColor: _settings.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: _settings.textColor),
        title: Text(
          widget.book.title,
          style: TextStyle(color: _settings.textColor, fontSize: 18),
        ),
        actions: [
          // 🔖 Bookmark (AppBar)
          IconButton(
            tooltip: 'Save Bookmark',
            icon: Icon(
              widget.book.bookmarkOffset > 0
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: _settings.textColor,
            ),
            onPressed: _toggleBookmark,
          ),

          // 🎨 Theme cycle
          IconButton(
            tooltip: 'Change background',
            icon: Icon(Icons.palette_outlined, color: _settings.textColor),
            onPressed: _cycleTheme,
          ),

          // ⚙ Settings
          IconButton(
            icon: Icon(Icons.settings, color: _settings.textColor),
            onPressed: () => setState(() => _showSettings = !_showSettings),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: isDark ? Colors.white12 : Colors.black12,
            valueColor: const AlwaysStoppedAnimation(Colors.deepPurpleAccent),
            minHeight: 4,
          ),
        ),
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: _settings.fontSize,
                color: _settings.textColor,
                height: _settings.lineHeight,
                fontFamily:
                    _settings.fontFamily == 'serif'
                        ? 'Times New Roman'
                        : _settings.fontFamily == 'mono'
                        ? 'monospace'
                        : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.book.title,
                    textAlign: _settings.textAlign,
                    style: TextStyle(
                      fontSize: _settings.fontSize + 6,
                      fontWeight: FontWeight.bold,
                      color: _settings.textColor,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Author
                  Text(
                    "by ${widget.book.author}",
                    textAlign: _settings.textAlign,
                    style: TextStyle(
                      fontSize: _settings.fontSize - 2,
                      fontStyle: FontStyle.italic,
                      color: _settings.textColor.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Body
                  Text(
                    widget.book.content.isEmpty
                        ? "No content available."
                        : widget.book.content,
                    textAlign: _settings.textAlign,
                  ),
                ],
              ),
            ),
          ),

          if (_showSettings)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SettingsPanel(
                settings: _settings,
                onChanged: () => setState(() {}),
              ),
            ),
        ],
      ),
    );
  }
}
