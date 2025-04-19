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
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                title: Text(book.title),
                subtitle: Text('Year: ${book.publishedYear} - Price: \$${book.price}'),
                leading: Text(book.isbn),
              );
            },
          );
        },
      ),
    );
  }
}