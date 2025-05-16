import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/barcode_services.dart';
import '../../models/book_model.dart';

class AuthorBooksPage extends StatelessWidget {
  final String authorName;

  const AuthorBooksPage({super.key, required this.authorName});

  @override
  Widget build(BuildContext context) {
    final barcodeService = Provider.of<BarcodeServices>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Books by $authorName"),
      ),
      body: FutureBuilder<List<Book>>(
        future: barcodeService.fetchBooksByAuthor(authorName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading books'));
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return const Center(child: Text('No books found for this author'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFFF7643), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "ISBN: ${book.isbn}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Published Year: ${book.publishedYear}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Category: ${book.category}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Price: \$${book.price}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
