class Book {
  final String id;
  final String title;
  final String author;
  final String filePath;
  final String content;
  DateTime lastRead;
  int currentPage;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.filePath,
    required this.content,
    DateTime? lastRead,
    this.currentPage = 0,
  }) : lastRead = lastRead ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'filePath': filePath,
    'content': content,
    'lastRead': lastRead.toIso8601String(),
    'currentPage': currentPage,
  };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'],
    title: json['title'],
    author: json['author'],
    filePath: json['filePath'],
    content: json['content'],
    lastRead: DateTime.parse(json['lastRead']),
    currentPage: json['currentPage'] ?? 0,
  );
}
