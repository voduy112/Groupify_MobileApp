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

  List<Document> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, List<Document>> get userDocuments => _userDocuments;

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
}
