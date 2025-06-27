import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../models/document.dart';
import '../../authentication/providers/auth_provider.dart';
import '../services/document_service.dart';

class DocumentProvider extends ChangeNotifier {
  final DocumentService _documentService = DocumentService();
  final AuthProvider authProvider;

  DocumentProvider({required this.authProvider});

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

  double _averageRating = 0.0;
  double get averageRating => _averageRating;

  int _totalRatings = 0;
  int get totalRatings => _totalRatings;

  double? _userRatedValue;
  double? get userRatedValue => _userRatedValue;

  String get currentUserId => authProvider.user?.id ?? '';

  //phan trang binh luan
  Map<String, List<Map<String, dynamic>>> comments = {};
  Map<String, int> commentsSkip = {};
  Map<String, int> commentsTotal = {};
  Map<String, bool> commentsHasMore = {};

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

  Future<void> fetchCountByGroupId(String groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      List<Document> documents =
          await _documentService.getAllDocumentsInGroup(groupId);
      _count = documents.length;
    } catch (e) {
      _error = 'Lỗi khi lấy số lượng tài liệu: $e';
      _count = 0;
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

  Future<bool> updateDocument(
    String documentId,
    String title,
    String description,
    dynamic image,
    dynamic mainFile, {
    String? groupId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _documentService.updateDocument(
        documentId,
        title,
        description,
        image,
        mainFile,
      );

      if (groupId != null) {
        await fetchDocumentsByGroupId(groupId);
      } else {
        // Nếu không có groupId, cập nhật local list luôn (nếu cần)
        final index = _documents.indexWhere((d) => d.id == documentId);
        if (index != -1) {
          _documents[index] = await _documentService.getDocument(documentId);
        }
      }

      return true;
    } catch (e) {
      _error = 'Lỗi khi cập nhật tài liệu: $e';
      print(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> fetchRatingOfDocument(String documentId) async {
    try {
      final data = await _documentService.getRatingOfDocument(documentId);
      _averageRating = double.tryParse(data['averageRating'].toString()) ?? 0.0;
      _totalRatings = data['totalRatings'] ?? 0;

      final userId = currentUserId;

      final ratings = data['ratings'] as List<dynamic>;
      final userRating = ratings.firstWhere(
        (r) => r['userId'] == userId,
        orElse: () => null,
      );

      _userRatedValue = userRating != null
          ? double.tryParse(userRating['value'].toString()) ?? 0.0
          : null;

      _error = null;
    } catch (e) {
      _averageRating = 0.0;
      _totalRatings = 0;
      _userRatedValue = null;
      _error = 'Lỗi khi lấy đánh giá: $e';
    }

    notifyListeners();
  }

  Future<bool> rateDocument(String documentId, double rating) async {
    try {
      await _documentService.rateDocument(
        documentId: documentId,
        userId: currentUserId,
        rating: rating,
      );
      await fetchRatingOfDocument(documentId);
      return true;
    } catch (e) {
      _error = 'Lỗi khi gửi đánh giá: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addComment(String documentId, String content) async {
    try {
      await _documentService.sendComment(
        documentId: documentId,
        content: content,
        userId: currentUserId,
      );

      // Tự giả định comment vừa gửi sẽ nằm đầu danh sách
      final latestComments =
          await _documentService.getComments(documentId, skip: 0, limit: 1);
      final newComment = latestComments['comments'].first;

      comments[documentId] = [newComment, ...?comments[documentId]];
      commentsTotal[documentId] = (commentsTotal[documentId] ?? 0) + 1;

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Lỗi khi gửi bình luận: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchComments(String documentId,
      {int skip = 0, int limit = 10}) async {
    try {
      final data = await _documentService.getComments(documentId,
          skip: skip, limit: limit);
      final newComments = List<Map<String, dynamic>>.from(data['comments']);

      if (skip == 0) {
        comments[documentId] = newComments;
      } else {
        comments[documentId] = [
          ...(comments[documentId] ?? []),
          ...newComments
        ];
      }

      commentsSkip[documentId] = (commentsSkip[documentId] ?? 0) + limit;
      commentsTotal[documentId] = data['total'] ?? 0;
      commentsHasMore[documentId] = data['hasMore'] ?? false;

      notifyListeners();
    } catch (e) {
      _error = 'Lỗi khi lấy bình luận: $e';
      notifyListeners();
    }
  }

  bool hasMoreComments(String documentId) =>
      commentsHasMore[documentId] ?? false;
  int getTotalCommentCount(String documentId) => commentsTotal[documentId] ?? 0;
  int getLoadedCommentCount(String documentId) =>
      comments[documentId]?.length ?? 0;

  //Xoa binh luan
  Future<bool> deleteComment(String documentId, String commentId) async {
    try {
      await _documentService.deleteComment(
        documentId: documentId,
        commentId: commentId,
        userId: currentUserId,
      );
      comments[documentId]?.removeWhere((cmt) => cmt['_id'] == commentId);

      if (commentsTotal.containsKey(documentId)) {
        commentsTotal[documentId] =
            (commentsTotal[documentId]! - 1).clamp(0, double.infinity).toInt();
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Lỗi khi xóa bình luận: $e';
      notifyListeners();
      return false;
    }
  }
}
