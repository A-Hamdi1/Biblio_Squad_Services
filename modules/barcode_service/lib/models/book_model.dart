class Book {
  final String isbn;
  final String title;
  final String author;
  final int publishedYear;
  final String category;
  final double price;


  Book({
    required this.isbn,
    required this.title,
    required this.author,
    required this.publishedYear,
    required this.category,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'isbn': isbn,
      'title': title,
      'author': author,
      'publishedYear': publishedYear,
      'category': category,
      'price': price,
    };
  }
}
