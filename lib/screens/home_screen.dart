import 'dart:convert';
import 'dart:typed_data';
import 'package:akshar_final/screens/reader_screen.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:akshar_final/models/books.dart';
import 'package:akshar_final/services/book_services.dart';
import 'package:akshar_final/screens/bookmarks_screen.dart';
import 'package:akshar_final/widgets/book_card.dart';

// HTML parser for EPUB
import 'package:html/parser.dart' as htmlparser;
// ZIP decode for EPUB
import 'package:archive/archive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookService _bookService = BookService();

  // ---------------- PICK FILE ----------------
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      withReadStream: true,
      type: FileType.custom,
      allowedExtensions: ['txt', 'epub', 'pdf'],
    );

    if (result == null) return;

    final picked = result.files.single;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Unable to read file.")));
      return;
    }

    final ext = picked.extension?.toLowerCase() ?? "";
    String content = "";
    Uint8List? coverBytes;

    try {
      // ------------ TXT ------------
      if (ext == "txt") {
        content = utf8.decode(bytes, allowMalformed: true);
      }
      // ------------ EPUB ------------
      else if (ext == "epub") {
        final archive = ZipDecoder().decodeBytes(bytes, verify: false);
        final List<String> texts = [];

        // Find images (possible cover)
        final List<ArchiveFile> imageFiles = [];
        for (final f in archive.files) {
          if (f.isFile) {
            final name = f.name.toLowerCase();
            if (name.endsWith(".png") ||
                name.endsWith(".jpg") ||
                name.endsWith(".jpeg") ||
                name.endsWith(".webp")) {
              imageFiles.add(f);
            }
          }
        }

        // Prefer file containing "cover"
        imageFiles.sort((a, b) {
          final aScore = a.name.toLowerCase().contains("cover") ? 0 : 1;
          final bScore = b.name.toLowerCase().contains("cover") ? 0 : 1;
          return aScore.compareTo(bScore);
        });

        if (imageFiles.isNotEmpty) {
          coverBytes = Uint8List.fromList(
            imageFiles.first.content as List<int>,
          );
        }

        // Extract text
        for (final f in archive.files) {
          if (!f.isFile) continue;

          final name = f.name.toLowerCase();
          if (name.endsWith(".xhtml") ||
              name.endsWith(".html") ||
              name.endsWith(".htm")) {
            final raw = utf8.decode(
              f.content as List<int>,
              allowMalformed: true,
            );

            final normalized = raw
                .replaceAll(RegExp(r"<br\s*/?>"), "\n")
                .replaceAll("</p>", "\n\n");

            final doc = htmlparser.parse(normalized);
            final text = doc.body?.text ?? "";
            final clean = text.replaceAll("\u00A0", " ").trim();

            if (clean.isNotEmpty) texts.add(clean);
          }
        }

        content = texts.join("\n\n").trim();
        if (content.isEmpty) {
          content = "No text could be extracted from this EPUB.";
        }
      }
      // ------------ PDF ------------
      else if (ext == "pdf") {
        content = ""; // Placeholder for now
      }
      // ------------ Unsupported ------------
      else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Unsupported type: $ext")));
        return;
      }

      // CREATE BOOK
      final book = Book(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: picked.name,
        author: "Unknown Author",
        filePath: picked.name,
        content: content,
        coverBytes: coverBytes,
      );

      _bookService.addBook(book);
      setState(() {});

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Added "${book.title}"')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final books = _bookService.getRecentBooks();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: _buildHeader(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: books.isEmpty ? _empty() : _adaptiveGrid(books),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickFile,
        icon: const Icon(Icons.add),
        label: const Text("Add Book"),
        backgroundColor: const Color(0xFF7C8CFF),
        foregroundColor: Colors.black,
      ),
    );
  }

  // ---------------- HEADER ----------------
  PreferredSizeWidget _buildHeader() {
    return AppBar(
      backgroundColor: const Color(0xFF121212),
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "Akshar",
        style: TextStyle(
          color: Color(0xFFBFD1FF),
          fontSize: 30,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          tooltip: "Bookmarks",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookmarksScreen()),
            );
          },
          icon: const Icon(Icons.bookmark, color: Color(0xFFBFD1FF)),
        ),
        IconButton(
          tooltip: "Add Book",
          onPressed: _pickFile,
          icon: const Icon(Icons.add_box_rounded, color: Color(0xFFBFD1FF)),
        ),
      ],
    );
  }

  // ---------------- EMPTY STATE ----------------
  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: const Color(0xFF7C8CFF).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 86,
              color: Color(0xFFBFD1FF),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Your shelf is empty",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Tap “Add Book” to import a TXT, EPUB, or PDF.",
            style: TextStyle(color: Colors.white.withOpacity(0.65)),
          ),
        ],
      ),
    );
  }

  // ---------------- GRID ----------------
  Widget _adaptiveGrid(List<Book> books) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        int cols = 2;
        if (w > 560) cols = 3;
        if (w > 840) cols = 4;
        if (w > 1100) cols = 5;

        return GridView.builder(
          itemCount: books.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 250,
          ),
          itemBuilder: (_, i) {
            final b = books[i];
            return BookCard(
              book: b,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ReaderScreen(book: b)),
                );
              },
              onDelete: () {
                _bookService.removeBook(b.id);
                setState(() {});
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Book removed")));
              },
            );
          },
        );
      },
    );
  }
}
