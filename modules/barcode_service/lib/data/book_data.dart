import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

Future<void> addMultipleBooks() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  DocumentReference setupDocRef =
      firestore.collection('setup').doc('books_added_flag');

  DocumentSnapshot snapshot = await setupDocRef.get();

  if (snapshot.exists) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    if (data['booksAdded'] == true) {
      print("Books have already been added.");
      return;
    }
  }

  List<Book> books = [
    Book(
        isbn: "9780743273565",
        title: "The Great Gatsby",
        author: "F. Scott Fitzgerald",
        publishedYear: 1925,
        category: "Classic",
        price: 15.99),
    Book(
        isbn: "9780062315007",
        title: "The Alchemist",
        author: "Paulo Coelho",
        publishedYear: 1988,
        category: "Fiction",
        price: 16.99),
    Book(
        isbn: "9781501110368",
        title: "It Ends with Us",
        author: "Colleen Hoover",
        publishedYear: 2016,
        category: "Romance",
        price: 16.99),
    Book(
        isbn: "9780593334836",
        title: "The Wedding People",
        author: "Alison Espach",
        publishedYear: 2024,
        category: "Fiction",
        price: 28.99),
    Book(
        isbn: "9781250178633",
        title: "Iron Flame",
        author: "Rebecca Yarros",
        publishedYear: 2023,
        category: "Fantasy",
        price: 29.99),
    Book(
        isbn: "9780593135198",
        title: "Atomic Habits",
        author: "James Clear",
        publishedYear: 2018,
        category: "Self-Help",
        price: 27.00),
    Book(
        isbn: "9781982109417",
        title: "The Silent Patient",
        author: "Alex Michaelides",
        publishedYear: 2019,
        category: "Thriller",
        price: 26.99),
    Book(
        isbn: "9780593653456",
        title: "The Anxious Generation",
        author: "Jonathan Haidt",
        publishedYear: 2024,
        category: "Nonfiction",
        price: 30.00),
    Book(
        isbn: "9780063204201",
        title: "Onyx Storm",
        author: "Rebecca Yarros",
        publishedYear: 2025,
        category: "Fantasy",
        price: 32.99),
    Book(
        isbn: "9780593441275",
        title: "James",
        author: "Percival Everett",
        publishedYear: 2024,
        category: "Historical Fiction",
        price: 28.00),
  ];

  WriteBatch batch = firestore.batch();

  for (var book in books) {
    DocumentReference docRef = firestore.collection('books').doc(book.isbn);
    batch.set(docRef, book.toMap());
  }

  await batch.commit();

  await setupDocRef.set({'booksAdded': true});

  print("All books added successfully!");
}
