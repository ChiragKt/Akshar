import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:akshar_final/models/books.dart';
import 'package:akshar_final/services/book_services.dart';
import 'package:akshar_final/screens/reader_screen.dart';
import 'package:akshar_final/widgets/book_card.dart';

// HTML parsing (to strip EPUB XHTML tags into text)
import 'package:html/parser.dart' as htmlparser;
// Pure-Dart zip reader to parse EPUB contents on web
import 'package:archive/archive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookService _bookService = BookService();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'epub', 'pdf'],
      allowMultiple: false,
      withData: true, // web-friendly
      withReadStream: true, // web-friendly (fallback)
    );

    if (result == null) return;
    final picked = result.files.single;

    // Ensure we always get bytes, even if .bytes is null on web
    Uint8List? bytes = picked.bytes;
    if (bytes == null && picked.readStream != null) {
      final bb = BytesBuilder();
      await for (final chunk in picked.readStream!) {
        bb.add(chunk);
      }
      bytes = bb.toBytes();
    }

    if (bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read file (no bytes)')),
      );
      return;
    }

    final ext = (picked.extension ?? '').toLowerCase();
    String content = '';

    try {
      if (ext == 'txt') {
        content = utf8.decode(bytes, allowMalformed: true);
      } else if (ext == 'epub') {
        // Parse EPUB (ZIP) on web: extract all .xhtml/.html files and strip tags
        final archive = ZipDecoder().decodeBytes(bytes, verify: false);
        final texts = <String>[];

        for (final f in archive.files) {
          if (!f.isFile) continue;
          final name = f.name.toLowerCase();
          if (name.endsWith('.xhtml') ||
              name.endsWith('.html') ||
              name.endsWith('.htm')) {
            final data = f.content as List<int>;
            final rawHtml = utf8.decode(data, allowMalformed: true);

            // Replace common HTML breaks with line breaks, then strip tags
            final normalized = rawHtml
                .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
                .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n');

            final doc = htmlparser.parse(normalized);
            final text = doc.body?.text ?? '';
            final clean =
                text
                    .replaceAll('\u00A0', ' ')
                    .replaceAll('&nbsp;', ' ')
                    .replaceAll('&amp;', '&')
                    .trim();

            if (clean.isNotEmpty) texts.add(clean);
          }
        }

        content = texts.join('\n\n').trim();
        if (content.isEmpty) {
          content = 'Unable to extract readable text from this EPUB.';
        }
      } else if (ext == 'pdf') {
        // For web: store PDF bytes as base64; ReaderScreen will show iframe blob
        content = base64Encode(bytes);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unsupported file type: .$ext')));
        return;
      }

      final book = Book(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: picked.name,
        author: 'Unknown Author',
        filePath:
            picked.name, // not used on web reader; content carries text/base64
        content: content,
      );

      _bookService.addBook(book);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Added ${book.title}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final books = _bookService.getRecentBooks();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: const Text(
          'Akshar',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        actions: const [SizedBox(width: 12)],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: books.isEmpty ? _buildEmptyState() : _buildBeautifulGrid(books),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickFile,
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 90,
              color: Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your library is empty',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a TXT, EPUB, or PDF to get started.',
            style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBeautifulGrid(List<Book> books) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount = 2;
        if (width > 520) crossAxisCount = 3;
        if (width > 820) crossAxisCount = 4;
        if (width > 1100) crossAxisCount = 5;

        return GridView.builder(
          itemCount: books.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 220,
            crossAxisSpacing: 14,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, i) {
            final book = books[i];
            return BookCard(
              book: book,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ReaderScreen(book: book)),
                );
              },
              onDelete: () {
                _bookService.removeBook(book.id);
                if (!mounted) return;
                setState(() {});
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Book removed')));
              },
            );
          },
        );
      },
    );
  }
}
