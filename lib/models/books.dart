class Book {
  final String id;
  final String title;
  final String author;
  final String filePath;
  final String content;

  DateTime lastRead;
  int currentPage;

  double bookmarkOffset; // <-- ADDED

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.filePath,
    required this.content,
    this.currentPage = 0,
    this.bookmarkOffset = 0.0, // <-- DEFAULT
    DateTime? lastRead,
  }) : lastRead = lastRead ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'filePath': filePath,
    'content': content,
    'currentPage': currentPage,
    'bookmarkOffset': bookmarkOffset, // <-- SAVE
    'lastRead': lastRead.toIso8601String(),
  };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'],
    title: json['title'],
    author: json['author'],
    filePath: json['filePath'],
    content: json['content'],
    currentPage: json['currentPage'] ?? 0,
    bookmarkOffset: (json['bookmarkOffset'] ?? 0).toDouble(), // <-- RESTORE
    lastRead: DateTime.parse(json['lastRead']),
  );
}
