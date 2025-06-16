import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../models/document.dart';
import '../../../services/api/dio_client.dart';

class DocumentService {
  final Dio _dio;

  DocumentService() : _dio = DioClient.instance;

  Future<List<Document>> getAllDocumentsInGroup(String groupId) async {
    try {
      final response = await _dio.get('/api/document/group/$groupId');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Document.fromJson(json)).toList();
      } else {
        throw Exception(
            "Lỗi khi lấy danh sách tài liệu: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi getAllDocumentInGroup: $e");
      rethrow;
    }
  }

  Future<Document> getDocument(String documentId) async {
    try {
      final response = await _dio.get('/api/document/$documentId');
      if (response.statusCode == 200) {
        return Document.fromJson(response.data);
      } else {
        throw Exception(
            "Lỗi khi lấy thông tin tài liệu: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi getDocument: $e");
      rethrow;
    }
  }

  // Hàm xin quyền lưu trữ
  Future<bool> requestStoragePermission() async {
    final statuses = await [
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();
    return statuses[Permission.storage]!.isGranted;
  }

  // Hàm download PDF
  Future<void> downloadPdf(BuildContext context, Document document) async {
    final url = document.mainFile;
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy file để tải xuống')),
      );
      return;
    }

    final hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần cấp quyền lưu trữ')),
      );
      return;
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        final fileName = url.split('/').last + '.pdf';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã tải về: $fileName')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tải thất bại (${response.statusCode})')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải: $e')),
      );
    }
  }

  Future<List<Document>> getDocuments() async {
    final response = await _dio.get('/api/document');
    print("response.data: ${response.data}");
    return (response.data as List)
        .map((json) => Document.fromJson(json))
        .toList();
  }

  Future<void> uploadDocument({
    required String title,
    required String description,
    required String uploaderId,
    required PlatformFile? imageFile,
    required PlatformFile? mainFile,
    required String groupId,
  }) async {
    try {
      final Map<String, dynamic> formMap = {
        'title': title,
        'description': description,
        'uploaderId': uploaderId,
        'groupId': groupId,
      };

      if (imageFile != null && imageFile.path != null) {
        formMap['image'] = await MultipartFile.fromFile(
          imageFile.path!,
          filename: imageFile.name,
        );
      }

      if (mainFile != null && mainFile.path != null) {
        formMap['mainFile'] = await MultipartFile.fromFile(
          mainFile.path!,
          filename: mainFile.name,
          contentType: MediaType('application', 'pdf'),
        );
      }

      final formData = FormData.fromMap(formMap);

      final response = await _dio.post('/api/document/', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Upload thành công: ${response.data}");
      } else {
        throw Exception("Upload thất bại: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi khi upload tài liệu: $e");
      rethrow;
    }
  }

  Future<void> deleteDocumentsInGroup(String groupId) async {
    try {
      final response = await _dio.delete('/api/document/group/$groupId');

      if (response.statusCode != 200) {
        throw Exception("Xóa tài liệu thất bại: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi deleteDocumentsInGroup: $e");
      rethrow;
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      final response = await _dio.delete('/api/document/$documentId');

      if (response.statusCode != 200) {
        throw Exception("Xóa tài liệu thất bại: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi deleteDocument: $e");
      rethrow;
    }
  }

  Future<void> updateDocument(
    String documentId,
    String title,
    String description,
    dynamic image, // PlatformFile hoặc String
    dynamic mainFile, // PlatformFile hoặc String
  ) async {
    print("updateDocument");
    print("image: $image");
    print("mainFile: $mainFile");
    print("documentId: $documentId");
    print("title: $title");
    print("description: $description");
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
    };

    if (image != null && image is PlatformFile && image.path != null) {
      data['image'] =
          await MultipartFile.fromFile(image.path!, filename: image.name);
    }
    if (mainFile != null && mainFile is PlatformFile && mainFile.path != null) {
      data['mainFile'] = await MultipartFile.fromFile(
        mainFile.path!,
        filename: mainFile.name,
        contentType: MediaType('application', 'pdf'),
      );
    }
  }
}
