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

  int _count = 0;
  int get count => _count;

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

  Future<bool> deleteDocumentsByGroupId(String groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _documentService.deleteDocumentsInGroup(groupId);

      _documents.removeWhere((doc) => doc.groupId == groupId);
      _count = 0;

      return true;
    } catch (e) {
      _error = 'Lỗi khi xóa tài liệu theo nhóm: $e';
      print("Lỗi từ DocumentProvider - deleteDocumentsByGroupId: $_error");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteDocumentById(String documentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _documentService.deleteDocument(documentId);

      _documents.removeWhere((doc) => doc.id == documentId);

      return true;
    } catch (e) {
      _error = 'Lỗi khi xóa tài liệu: $e';
      print("Lỗi từ DocumentProvider - deleteDocumentById: $_error");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDocument(String documentId, String title,
      String description, dynamic image, dynamic mainFile,
      {String? groupId}) async {
    await _documentService.updateDocument(
      documentId,
      title,
      description,
      image,
      mainFile,
    );
    if (groupId != null) {
      await fetchDocumentsByGroupId(groupId);
    }
    notifyListeners();
  }
}
