import 'package:akshar_final/models/books.dart';
import 'package:akshar_final/screens/reader_screen.dart';
import 'package:akshar_final/services/book_services.dart';
import 'package:akshar_final/widgets/book_card.dart' show BookCard;
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookService _bookService = BookService();

  void _openFilePicker() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Book'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'In a production app, this would open a file picker.',
                ),
                const SizedBox(height: 16),
                const Text('Supported formats: TXT, EPUB, PDF'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddBookDialog();
                  },
                  child: const Text('Simulate Adding Book'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _showAddBookDialog() {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Book'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: authorController,
                    decoration: const InputDecoration(
                      labelText: 'Author',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    final book = Book(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text,
                      author:
                          authorController.text.isEmpty
                              ? 'Unknown Author'
                              : authorController.text,
                      filePath: '/simulated/path',
                      content:
                          contentController.text.isEmpty
                              ? 'No content provided'
                              : contentController.text,
                    );
                    _bookService.addBook(book);
                    setState(() {});
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Book added successfully!')),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recentBooks = _bookService.getRecentBooks();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6C63FF),
        title: const Text(
          'Akshar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body:
          recentBooks.isEmpty
              ? _buildEmptyState()
              : _buildBookList(recentBooks),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openFilePicker,
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
        backgroundColor: const Color(0xFFFF6584),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.library_books_outlined,
              size: 80,
              color: const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No books yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the button below to add your first book',
            style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookList(List<Book> books) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Books',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                return BookCard(
                  book: books[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReaderScreen(book: books[index]),
                      ),
                    );
                    setState(() {});
                  },
                  onDelete: () {
                    _bookService.removeBook(books[index].id);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Book removed')),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
