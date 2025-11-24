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
  final ReadingSettings _settings = ReadingSettings();
  final BookService _bookService = BookService();
  final ScrollController _scrollController = ScrollController();

  bool _showSettings = false;
  bool _showSearch = false;

  // SEARCH
  final TextEditingController _searchCtrl = TextEditingController();
  final List<int> _matches = [];
  int _matchIndex = 0;

  @override
  void initState() {
    super.initState();

    // Jump to saved bookmark
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          widget.book.bookmarkOffset > 0 &&
          widget.book.bookmarkOffset <
              _scrollController.position.maxScrollExtent) {
        _scrollController.jumpTo(widget.book.bookmarkOffset);
      }
    });

    // Save new scroll offset as bookmark
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        widget.book.bookmarkOffset = _scrollController.offset;
      }
    });

    // Update "last read" timestamp
    _bookService.updateLastRead(widget.book.id);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ---------------- SEARCH ----------------
  void _runSearch(String query) {
    _matches.clear();
    _matchIndex = 0;

    if (query.trim().isEmpty) {
      setState(() {});
      return;
    }

    final lowerText = widget.book.content.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int start = 0;
    while (true) {
      final idx = lowerText.indexOf(lowerQuery, start);
      if (idx == -1) break;
      _matches.add(idx);
      start = idx + lowerQuery.length;
    }

    setState(() {});
    if (_matches.isNotEmpty) {
      _jumpToMatch(0);
    }
  }

  void _jumpToMatch(int index) {
    if (_matches.isEmpty) return;

    _matchIndex = index.clamp(0, _matches.length - 1);
    final charIndex = _matches[_matchIndex];

    final ratio = charIndex / widget.book.content.length;
    final target = ratio * _scrollController.position.maxScrollExtent;

    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );

    setState(() {});
  }

  // --------- PROGRESS ---------
  double get _progress {
    if (!_scrollController.hasClients) return 0;
    if (_scrollController.position.maxScrollExtent == 0) return 0;

    return (_scrollController.offset /
            _scrollController.position.maxScrollExtent)
        .clamp(0.0, 1.0);
  }

  void _saveBookmark() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Bookmark saved")));
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
          IconButton(
            icon: Icon(Icons.search, color: _settings.textColor),
            onPressed: () => setState(() => _showSearch = !_showSearch),
          ),
          IconButton(
            icon: Icon(Icons.bookmark_add_outlined, color: _settings.textColor),
            onPressed: _saveBookmark,
          ),
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
            valueColor: AlwaysStoppedAnimation(Colors.deepPurpleAccent),
            minHeight: 4,
          ),
        ),
      ),

      body: Stack(
        children: [
          // BOOK CONTENT
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: _settings.fontSize,
                color: _settings.textColor,
                height: _settings.lineHeight,
                fontFamily: _settings.fontFamily,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    "by ${widget.book.author}",
                    textAlign: _settings.textAlign,
                    style: TextStyle(
                      fontSize: _settings.fontSize - 2,
                      fontStyle: FontStyle.italic,
                      color: _settings.textColor.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 20),
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

          // SEARCH BAR
          if (_showSearch)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(12),
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search),
                      const SizedBox(width: 6),

                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: _runSearch,
                          decoration: const InputDecoration(
                            hintText: "Search in book...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      if (_matches.isNotEmpty) ...[
                        Text(
                          "${_matchIndex + 1}/${_matches.length}",
                          style: TextStyle(color: _settings.textColor),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_drop_up),
                          onPressed: () => _jumpToMatch(_matchIndex - 1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_drop_down),
                          onPressed: () => _jumpToMatch(_matchIndex + 1),
                        ),
                      ],

                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _showSearch = false;
                            _searchCtrl.clear();
                            _matches.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // SETTINGS PANEL
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
