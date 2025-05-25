import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/document_share_service.dart';
import '../../../models/document.dart';

class DocumentShareProvider extends ChangeNotifier {
  final DocumentShareService _documentShareService;
  List<Document> _documents = [];
  bool _isLoading = false;
  String? _error;

  List<Document> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DocumentShareProvider() : _documentShareService = DocumentShareService();

  Future<void> fetchDocuments() async {
    _isLoading = true;
    notifyListeners();

    try {
      _documents = await _documentShareService.getDocuments();
      print("documents: ${_documents}");
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
