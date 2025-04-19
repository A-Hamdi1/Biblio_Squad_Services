import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/document_scan_model.dart';
import '../../../core/providers/document_provider.dart';
import 'latest_documents_screen.dart';

class DocumentCategoryPage extends StatefulWidget {
  final String categoryTitle;
  const DocumentCategoryPage({
    super.key,
    required this.categoryTitle,
  });

  @override
  State<DocumentCategoryPage> createState() => _DocumentCategoryPageState();
}

class _DocumentCategoryPageState extends State<DocumentCategoryPage> {
  List<DocumentModel> categoryDocuments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCategoryData();
  }

  Future<void> loadCategoryData() async {
    setState(() {
      isLoading = true;
    });

    final documentProvider = context.read<DocumentProvider>();
    categoryDocuments = await documentProvider.getDocumentsByCategory(widget.categoryTitle);

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Document ${widget.categoryTitle}'),
      ),
      body: RefreshIndicator(
        onRefresh: loadCategoryData,
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : categoryDocuments.isEmpty
                  ? Center(
                child: Text(
                  "${widget.categoryTitle} is empty",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
                ),
              )
                  : LatestDocumentsPage(
                documents: categoryDocuments,
              ),
            ),
          ],
        ),
      ),
    );
  }
}