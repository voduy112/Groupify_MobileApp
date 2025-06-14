import 'package:flutter/material.dart';
import '../../../models/document.dart';
import '../services/document_service.dart';

class DocumentProvider extends ChangeNotifier {
  final DocumentService _documentService = DocumentService();

  List<Document> _documents = [];
  List<Document> get documents => _documents;

  Document? _selectedDocument;
  Document? get selectedDocument => _selectedDocument;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchDocumentsByGroupId(String groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _documents = await _documentService.getAllDocumentsInGroup(groupId);
    } catch (e) {
      _error = 'Lỗi khi lấy danh sách tài liệu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDocumentById(String documentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedDocument = await _documentService.getDocument(documentId);
    } catch (e) {
      _error = 'Lỗi khi lấy tài liệu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _documents = [];
    _selectedDocument = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
