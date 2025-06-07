import 'package:file_picker/file_picker.dart';
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

  Future<void> fetchDocuments(groupId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _documents = await _documentService.getDocuments();
      print("documents: ${_documents}");
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadDocument({
    required String title,
    required String description,
    required String uploaderId,
    required String groupId,
    required PlatformFile? imageFile,
    required PlatformFile? mainFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _documentService.uploadDocument(
        title: title,
        description: description,
        uploaderId: uploaderId,
        groupId: groupId,
        imageFile: imageFile,
        mainFile: mainFile,
      );

      // Optionally fetch updated documents list
      await fetchDocumentsByGroupId(groupId);

      return true;
    } catch (e) {
      _error = e.toString();
      print("Lỗi từ DocumentProvider: $_error");
      return false;
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
