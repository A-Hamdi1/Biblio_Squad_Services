import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pdf_export_screen.dart';
import 'package:provider/provider.dart';
import '../../core/providers/document_provider.dart';
import '../widgets/home_header.dart';

class TextRecognitionScreen extends StatefulWidget {
  final File imageFile;

  const TextRecognitionScreen({super.key, required this.imageFile});

  @override
  _TextRecognitionScreenState createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  bool _isImageVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DocumentProvider>(context, listen: false)
          .processImage(widget.imageFile);
    });
  }

  Future<void> _copyToClipboard() async {
    final text = Provider.of<DocumentProvider>(context, listen: false)
        .currentDocument?.extractedText ?? '';

    try {
      await Clipboard.setData(ClipboardData(text: text));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Texte copié!'),
          duration: Duration(milliseconds: 800),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la copie'),
          backgroundColor: Colors.red,
        ),
      );
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<DocumentProvider>(
          builder: (context, documentProvider, child) {
            if (documentProvider.isProcessing) {
              return const Center(child: CircularProgressIndicator());
            }

            final document = documentProvider.currentDocument;
            final extractedText = document?.extractedText ?? 'No text found';

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: HomeHeader(
                    svgSrc: "packages/ocr_service/assets/images/arrow_left.svg",
                    press: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.image, color: Colors.white),
                            label: const Text("Show Image"),
                            onPressed: () {
                              setState(() {
                                _isImageVisible = !_isImageVisible;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Color(0xFFFF7643),
                              textStyle: const TextStyle(fontSize: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_isImageVisible)
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  widget.imageFile,
                                  fit: BoxFit.contain,
                                  height: 300,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                          Text(
                            extractedText,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.copy, color: Colors.white),
                        label: const Text("Copier le texte"),
                        onPressed: _copyToClipboard,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: const Color(0xFFFF7643),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                        label: const Text("Export as PDF"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PdfExportScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Color(0xFFFF7643),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}