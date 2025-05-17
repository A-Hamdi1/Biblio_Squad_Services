import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:provider/provider.dart';
import '../../../models/document_scan_model.dart';
import '../../../core/providers/document_provider.dart';
import 'home_screen.dart';

class EditDocumentPage extends StatefulWidget {
  final DocumentModel document;

  const EditDocumentPage({super.key, required this.document});

  @override
  State<EditDocumentPage> createState() => _EditDocumentPageState();
}

class _EditDocumentPageState extends State<EditDocumentPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _category;
  List<String> _images = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.document.name ?? '';
    _category = widget.document.category ?? '';
    _images = widget.document.path ?? [];
  }

  Future<void> _pickImages() async {
    final documentOptions = DocumentScannerOptions();

    try {
      final documentScanner = DocumentScanner(options: documentOptions);
      DocumentScanningResult result = await documentScanner.scanDocument();

      setState(() {
        _images.addAll(result.images);
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to scan document'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveDocument() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        final updatedDocument = DocumentModel(
          id: widget.document.id,
          name: _name,
          category: _category,
          path: _images,
          createdAt: widget.document.createdAt,
        );

        final success =
            await Provider.of<DocumentsProvider>(context, listen: false)
                .saveDocument(updatedDocument);

        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document updated successfully'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update document'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Document',
          style: TextStyle(fontSize: 17.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveDocument,
            color: const Color(0xFFFF7643),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _name,
                      decoration:
                          const InputDecoration(labelText: 'Document Name'),
                      onSaved: (value) {
                        _name = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a document name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      onSaved: (value) {
                        _category = value ?? '';
                      },
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    const Text('Images'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: _images.map((imagePath) {
                        return Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Image.file(
                              File(imagePath),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _images.remove(imagePath);
                                });
                              },
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _pickImages,
                      child: const Text('Scan Document'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
