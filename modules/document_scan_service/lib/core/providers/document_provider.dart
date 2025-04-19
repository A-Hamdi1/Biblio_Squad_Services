import 'package:flutter/foundation.dart';
import '../../models/document_scan_model.dart';
import '../../data/document_local_datasource.dart';

class DocumentProvider extends ChangeNotifier {
  List<DocumentModel> _documents = [];
  bool _isLoading = false;
  String? _error;

  List<DocumentModel> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDocuments() async {
    _setLoading(true);
    try {
      _documents = await DocumentLocalDatasource.instance.getAllDocuments();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<List<DocumentModel>> getDocumentsByCategory(String category) async {
    _setLoading(true);
    try {
      final categoryDocs = await DocumentLocalDatasource.instance.getDocumentByCategory(category);
      _error = null;
      return categoryDocs;
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveDocument(DocumentModel document) async {
    _setLoading(true);
    try {
      await DocumentLocalDatasource.instance.saveDocument(document);
      await loadDocuments();
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteDocument(int documentId) async {
    _setLoading(true);
    try {
      final documentToDelete = _documents.firstWhere((doc) => doc.id == documentId);

      final result = await DocumentLocalDatasource.instance.deleteDocument(documentId);

      if (result > 0) {
        _documents.removeWhere((doc) => doc.id == documentId);
        notifyListeners();
        _error = null;
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}