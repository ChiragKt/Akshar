// Flutter Web reader:
// - TXT/EPUB: show text
// - PDF: iframe blob URL (no native plugins)

import 'dart:convert';
import 'dart:js_interop';

// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;

import 'package:web/web.dart' as html; // Replaces deprecated dart:html
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
  bool _showSettings = false;

  bool get _isPdf =>
      widget.book.title.toLowerCase().endsWith('.pdf') ||
      widget.book.filePath.toLowerCase().endsWith('.pdf');

  // PDF iframe
  String? _viewTypeId;
  html.HTMLIFrameElement? _iframe;
  String? _blobUrl;

  @override
  void initState() {
    super.initState();
    _bookService.updateLastRead(widget.book.id);
    if (_isPdf) _initPdfViewer();
  }

  void _initPdfViewer() {
    try {
      if (widget.book.content.isEmpty) return;

      final bytes = base64Decode(widget.book.content);

      final blob = html.Blob(
        [bytes] as JSArray<html.BlobPart>,
        html.BlobPropertyBag(type: "application/pdf"),
      );
      _blobUrl = html.URL.createObjectURL(blob);

      _iframe =
          html.HTMLIFrameElement()
            ..src = _blobUrl!
            ..style.border = "none"
            ..style.width = "100%"
            ..style.height = "100%";

      _viewTypeId = "pdf-${widget.book.id}";

      ui.platformViewRegistry.registerViewFactory(
        _viewTypeId!,
        (int _) => _iframe!,
      );

      setState(() {});
    } catch (e) {
      debugPrint("PDF iframe error: $e");
    }
  }

  @override
  void dispose() {
    if (_blobUrl != null) {
      html.URL.revokeObjectURL(_blobUrl!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isPdf ? _buildPdf() : _buildTextReader();
  }

  // ---------------- PDF VIEW ----------------
  Widget _buildPdf() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.book.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body:
          _viewTypeId == null
              ? const Center(child: CircularProgressIndicator())
              : HtmlElementView(viewType: _viewTypeId!),
    );
  }

  // ---------------- TEXT VIEW ----------------
  Widget _buildTextReader() {
    return Scaffold(
      backgroundColor: _settings.backgroundColor,
      appBar: AppBar(
        backgroundColor: _settings.backgroundColor,
        iconTheme: IconThemeData(color: _settings.textColor),
        title: Text(
          widget.book.title,
          style: TextStyle(color: _settings.textColor),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: _settings.textColor),
            onPressed: () => setState(() => _showSettings = !_showSettings),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Text(
              widget.book.content.isEmpty
                  ? "No content available."
                  : widget.book.content,
              style: TextStyle(
                fontSize: _settings.fontSize,
                color: _settings.textColor,
                height: 1.7,
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
                backgroundColors: const [
                  Color(0xffffffff),
                  Color(0xfffff8dc),
                  Color(0xffe8dcc0),
                  Color(0xff2c2c2c),
                ],
                onSettingsChanged: () => setState(() {}),
              ),
            ),
        ],
      ),
    );
  }
}
