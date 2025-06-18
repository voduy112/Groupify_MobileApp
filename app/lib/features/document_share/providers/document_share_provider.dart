import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/document_share_service.dart';
import '../../../models/document.dart';
import 'package:file_picker/file_picker.dart';

class DocumentShareProvider extends ChangeNotifier {
  final DocumentShareService _documentShareService;
  List<Document> _documents = [];
  bool _isLoading = false;
  String? _error;
  Map<String, List<Document>> _userDocuments = {};
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isFetchingMore = false;

  List<Document> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, List<Document>> get userDocuments => _userDocuments;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get isFetchingMore => _isFetchingMore;

  DocumentShareProvider() : _documentShareService = DocumentShareService();

  Future<void> fetchDocuments({int page = 1}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _documentShareService.getDocuments(page: page);
      if (page == 1) {
        _documents = response.documents;
      } else {
        _documents.addAll(response.documents);
      }
      _currentPage = page;
      _totalPages = response.totalPages;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreDocuments() async {
    if (_isFetchingMore || _currentPage >= _totalPages) return;
    _isFetchingMore = true;
    notifyListeners();
    try {
      final nextPage = _currentPage + 1;
      final response = await _documentShareService.getDocuments(page: nextPage);
      _documents.addAll(response.documents);
      _currentPage = nextPage;
      _totalPages = response.totalPages;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> uploadDocument({
    required String title,
    required String description,
    required String uploaderId,
    required PlatformFile? imageFile,
    required PlatformFile? mainFile,
  }) async {
    _isLoading = true;
    notifyListeners();
    await _documentShareService.uploadDocument(
      title: title,
      description: description,
      uploaderId: uploaderId,
      imageFile: imageFile,
      mainFile: mainFile,
    );
    _error = null;
    _isLoading = false;
    notifyListeners();
    await fetchDocuments();
  }

  Future<void> fetchDocumentsByUserId(String userId) async {
    _isLoading = true;
    notifyListeners();
    final docs = await _documentShareService.getDocumentsByUserId(userId);
    _userDocuments[userId] = docs;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteDocument(String documentId, {String? userId}) async {
    await _documentShareService.deleteDocument(documentId);
    if (userId != null) {
      _userDocuments[userId]?.removeWhere((doc) => doc.id == documentId);
      notifyListeners();
    } else {
      await fetchDocuments();
    }
  }

  Future<void> updateDocument(String documentId, String title,
      String description, dynamic image, dynamic mainFile,
      {String? userId}) async {
    await _documentShareService.updateDocument(
      documentId,
      title,
      description,
      image,
      mainFile,
    );
    if (userId != null) {
      await fetchDocumentsByUserId(userId);
    } else {
      await fetchDocuments();
    }
    notifyListeners();
  }

  Future<List<Document>> searchDocument(String query) async {
    return await _documentShareService.searchDocument(query);
  }
}
