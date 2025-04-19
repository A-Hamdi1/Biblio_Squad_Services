import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/book_model.dart';

class BarcodeServices {
  final BarcodeScanner _scanner = BarcodeScanner();

  Future<List<CameraDescription>> getAvailableCameras() async {
    try {
      return await availableCameras();
    } catch (e) {
      return [];
    }
  }

  Future<CameraController> initializeCamera(CameraDescription camera) async {
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await controller.initialize();
    return controller;
  }

  Future<String?> processImage(CameraImage image) async {
    try {
      final inputImage = _convertToInputImage(image);
      final barcodes = await _scanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        return barcodes.first.rawValue;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  InputImage _convertToInputImage(CameraImage image) {
    // Vous devrez implémenter cette méthode comme dans votre code original
    // Conversion de CameraImage en InputImage pour ML Kit
    // ...

    // Code simplifié pour l'exemple
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  String _normalizeIsbn(String isbn) {
    return isbn.replaceAll(RegExp(r'[- ]'), '');
  }

  Future<Book?> fetchBookDetails(String isbn) async {
    try {
      final normalizedIsbn = _normalizeIsbn(isbn);
      final querySnapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('isbn', isEqualTo: normalizedIsbn)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data();
        return Book(
          isbn: data['isbn'],
          title: data['title'],
          author: data['author'],
          publishedYear: data['publishedYear'],
          category: data['category'],
          price: data['price'],
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Book>> fetchBooksByAuthor(String author) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('author', isEqualTo: author)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Book(
          isbn: data['isbn'],
          title: data['title'],
          author: data['author'],
          publishedYear: data['publishedYear'],
          category: data['category'],
          price: data['price'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  void close() {
    _scanner.close();
  }
}