import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:akshar_final/models/books.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        width: 260, // Nice Apple Books size
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===============================
            // COVER (NO OVERFLOW EVER)
            // ===============================
            AspectRatio(
              aspectRatio: 3 / 4, // Book ratio
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff6c63ff), Color(0xff9770ff)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child:
                      book.coverBytes != null
                          ? Image.memory(book.coverBytes!, fit: BoxFit.cover)
                          : Center(
                            child: Icon(
                              Icons.menu_book_rounded,
                              size: 88,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 24,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                Shadow(
                                  blurRadius: 48,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ],
                            ),
                          ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ===============================
            // TITLE
            // ===============================
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            // ===============================
            // AUTHOR
            // ===============================
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 12),

            // ===============================
            // FOOTER (LAST READ + DELETE)
            // ===============================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Last read: Today",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
