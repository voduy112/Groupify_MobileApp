import 'package:dio/dio.dart';
import '../../../models/document.dart';
import '../../../services/api/dio_client.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';

class DocumentShareService {
  final Dio _dio;

  DocumentShareService() : _dio = DioClient.instance;

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
  }) async {
    print("imageFile: ${imageFile?.path}");
    print("mainFile: ${mainFile?.name}");
    print("mainFile path: ${mainFile?.path}");
    print("mainFile size: ${mainFile?.size}");
    print("title: $title");
    print("description: $description");
    print("uploaderId: $uploaderId");
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'uploaderId': uploaderId,
    };

    if (imageFile != null && imageFile.path != null) {
      data['image'] = await MultipartFile.fromFile(imageFile.path!,
          filename: imageFile.name);
    }
    if (mainFile != null && mainFile.path != null) {
      data['mainFile'] = await MultipartFile.fromFile(
        mainFile.path!,
        filename: mainFile.name,
        contentType: MediaType('application', 'pdf'),
      );
    }

    final formData = FormData.fromMap(data);
    print("formData: ${formData.fields}");
    print("formData: ${formData.files}");

    final response = await _dio.post(
      '/api/document/',
      data: formData,
    );
    print("response.data: ${response.data}");
  }

  Future<List<Document>> getDocumentsByUserId(String userId) async {
    final response = await _dio.get('/api/document/user/$userId');
    return (response.data as List)
        .map((json) => Document.fromJson(json))
        .toList();
  }

  Future<void> deleteDocument(String documentId) async {
    final response = await _dio.delete('/api/document/$documentId');
    return response.data;
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

    final formData = FormData.fromMap(data);
    print("formData: ${formData.fields}");
    print("formData: ${formData.files}");
    final response =
        await _dio.put('/api/document/$documentId', data: formData);
    return response.data;
  }
}
