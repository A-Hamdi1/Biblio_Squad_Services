import 'package:flutter/material.dart';
import '../../models/book_model.dart';

class BookDetailsCard extends StatelessWidget {
  final Book book;
  final Function(String) onAuthorTap;

  const BookDetailsCard({
    super.key,
    required this.book,
    required this.onAuthorTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Expanded(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFFF7643), width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text("Author: ", style: TextStyle(fontSize: 16)),
                      GestureDetector(
                        onTap: () => onAuthorTap(book.author),
                        child: Text(
                          book.author,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("Published Year: ${book.publishedYear}",
                      style: const TextStyle(fontSize: 16)),
                  Text("Category: ${book.category}",
                      style: const TextStyle(fontSize: 16)),
                  Text("Price: \$${book.price}",
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
