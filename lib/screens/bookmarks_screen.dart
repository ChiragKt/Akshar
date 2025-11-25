import 'package:flutter/material.dart';
import 'package:akshar_final/models/books.dart';
import 'package:akshar_final/services/book_services.dart';
import 'package:akshar_final/screens/reader_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BookService service = BookService();
    final List<Book> bookmarkedBooks =
        service.books.where((b) => b.bookmarkOffset > 0).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          "Saved Bookmarks",
          style: TextStyle(
            color: Color(0xFFBFD1FF),
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      body:
          bookmarkedBooks.isEmpty
              ? _emptyBookmarks()
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: bookmarkedBooks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final book = bookmarkedBooks[i];
                  return _BookmarkTile(
                    book: book,
                    onOpen: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReaderScreen(book: book),
                        ),
                      );
                    },
                    onClear: () {
                      book.bookmarkOffset = 0;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Removed bookmark for '${book.title}'"),
                        ),
                      );
                      (context as Element).markNeedsBuild();
                    },
                  );
                },
              ),
    );
  }

  // EMPTY UI
  Widget _emptyBookmarks() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 90,
            color: Colors.white.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            "No bookmarks yet",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Bookmarks you save will appear here.",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// BOOKMARK LIST TILE
// ------------------------------------------------------------
class _BookmarkTile extends StatelessWidget {
  final Book book;
  final VoidCallback onOpen;
  final VoidCallback onClear;

  const _BookmarkTile({
    required this.book,
    required this.onOpen,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        onTap: onOpen,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 55,
            height: 80,
            child:
                book.coverBytes != null
                    ? Image.memory(book.coverBytes!, fit: BoxFit.cover)
                    : Container(
                      color: const Color(0xFF272727),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 40,
                        color: Colors.white70,
                      ),
                    ),
          ),
        ),
        title: Text(
          book.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          "Tap to resume reading",
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.redAccent),
          onPressed: onClear,
        ),
      ),
    );
  }
}
