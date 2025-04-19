import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/document_scan_model.dart';
import '../../../core/providers/document_provider.dart';
import 'detail_document_screen.dart';

class LatestDocumentsPage extends StatelessWidget {
  final List<DocumentModel> documents;
  const LatestDocumentsPage({
    super.key,
    required this.documents,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: documents.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3 / 2,
        ),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[200],
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailDocumentPage(
                          document: documents[index],
                        ))).then((_) {
                  Provider.of<DocumentProvider>(context, listen: false).loadDocuments();
                });
              },
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: documents[index].path!.map((imagePath) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(imagePath),
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width * 0.8,
                                colorBlendMode: BlendMode.colorBurn,
                                color: const Color.fromARGB(255, 84, 180, 189).withOpacity(0.2),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    documents[index].name!,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 84, 180, 189),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}