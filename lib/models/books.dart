import 'dart:typed_data';
import 'dart:convert';

class Book {
  final String id;
  final String title;
  final String author;
  final String filePath;
  final String content;

  /// Optional cover image (EPUB). Shown in the library grid.
  Uint8List? coverBytes;

  DateTime lastRead;
  int currentPage;

  /// Saved scroll position (for ReaderScreen)
  double bookmarkOffset;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.filePath,
    required this.content,
    this.coverBytes,
    DateTime? lastRead,
    this.currentPage = 0,
    this.bookmarkOffset = 0.0,
  }) : lastRead = lastRead ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'filePath': filePath,
    'content': content,
    'lastRead': lastRead.toIso8601String(),
    'currentPage': currentPage,
    'bookmarkOffset': bookmarkOffset,
    // Persist cover as base64 (optional)
    'coverBase64': coverBytes == null ? null : base64Encode(coverBytes!),
  };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'],
    title: json['title'],
    author: json['author'],
    filePath: json['filePath'],
    content: json['content'],
    lastRead: DateTime.parse(json['lastRead']),
    currentPage: (json['currentPage'] ?? 0) as int,
    bookmarkOffset: (json['bookmarkOffset'] ?? 0.0).toDouble(),
    coverBytes:
        (json['coverBase64'] == null)
            ? null
            : Uint8List.fromList(base64Decode(json['coverBase64'])),
  );
}
