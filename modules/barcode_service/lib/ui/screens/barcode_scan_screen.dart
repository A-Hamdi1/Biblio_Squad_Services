import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/barcode_provider.dart';
import '../widgets/author_books_page.dart';
import '../widgets/book_details_card.dart';

class BarcodeScanScreen extends StatelessWidget {
  const BarcodeScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
      ),
      body: Consumer<BarcodeProvider>(
        builder: (context, provider, child) {
          switch (provider.status) {
            case BarcodeScanStatus.initializing:
              return const Center(child: CircularProgressIndicator());

            case BarcodeScanStatus.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(provider.errorMessage ?? 'An error occurred'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );

            case BarcodeScanStatus.scanning:
            case BarcodeScanStatus.found:
            case BarcodeScanStatus.notFound:
              return Column(
                children: [
                  // Camera preview
                  Expanded(
                    child: provider.cameraController != null
                        ? CameraPreview(provider.cameraController!)
                        : const Center(child: CircularProgressIndicator()),
                  ),

                  // Barcode results
                  if (provider.scannedBarcode.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Scanned ISBN: ${provider.scannedBarcode}"),
                          const SizedBox(height: 8),

                          if (provider.status == BarcodeScanStatus.scanning)
                            const Center(child: CircularProgressIndicator())
                          else if (provider.status == BarcodeScanStatus.found)
                            BookDetailsCard(
                              book: provider.bookDetails!,
                              onAuthorTap: (author) => _navigateToAuthorBooks(context, author),
                            )
                          else
                            const Text(
                              "Book not found",
                              style: TextStyle(fontSize: 18, color: Colors.red),
                            ),
                        ],
                      ),
                    ),
                ],
              );
          }
        },
      ),
    );
  }

  void _navigateToAuthorBooks(BuildContext context, String author) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuthorBooksPage(authorName: author),
      ),
    );
  }
}