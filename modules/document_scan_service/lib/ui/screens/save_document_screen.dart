import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/document_scan_model.dart';
import '../../../core/providers/document_provider.dart';

class SaveDocumentPage extends StatefulWidget {
  final List<String> pathImage;

  const SaveDocumentPage({
    super.key,
    required this.pathImage,
  });

  @override
  State<SaveDocumentPage> createState() => _SaveDocumentPageState();
}

class _SaveDocumentPageState extends State<SaveDocumentPage> {
  TextEditingController? nameController;
  String? selectCategory;

  final List<String> categories = ['Pamphlet', 'Poetry', 'Novel'];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
  }

  @override
  void dispose() {
    nameController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Document'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.pathImage.map((path) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Document Name',
            ),
          ),
          const SizedBox(height: 16.0),
          DropdownButtonFormField<String>(
            value: selectCategory,
            onChanged: (String? value) {
              setState(() {
                selectCategory = value;
              });
            },
            items: categories
                .map((e) => DropdownMenuItem<String>(
              value: e,
              child: Text(e),
            ))
                .toList(),
            decoration: const InputDecoration(
              labelText: 'Category',
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
      bottomNavigationBar: Consumer<DocumentProvider>(
          builder: (context, documentProvider, child) {
            return InkWell(
              onTap: () async {
                // save document
                try {
                  if (nameController!.text.isEmpty || selectCategory == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please complete the data'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  DocumentModel model = DocumentModel(
                    name: nameController!.text,
                    path: widget.pathImage,
                    category: selectCategory!,
                    createdAt:
                    DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()),
                  );

                  final success = await documentProvider.saveDocument(model);

                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Saved Document'),
                        backgroundColor: Color(0xFFFF7643),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    final snackBar = SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 52,
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 84, 180, 189),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: documentProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Save Document",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffFFFFFF),
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }
}