import 'package:akshar_final/models/books.dart';

class BookService {
  static final BookService _instance = BookService._internal();
  factory BookService() => _instance;
  BookService._internal();

  final List<Book> _books = [];

  List<Book> get books => List.unmodifiable(_books);

  void addBook(Book book) {
    _books.add(book);
  }

  void removeBook(String id) {
    _books.removeWhere((book) => book.id == id);
  }

  Book? getBook(String id) {
    try {
      return _books.firstWhere((book) => book.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateLastRead(String id) {
    final book = getBook(id);
    if (book != null) {
      book.lastRead = DateTime.now();
    }
  }

  List<Book> getRecentBooks() {
    final sortedBooks = List<Book>.from(_books);
    sortedBooks.sort((a, b) => b.lastRead.compareTo(a.lastRead));
    return sortedBooks;
  }
}
