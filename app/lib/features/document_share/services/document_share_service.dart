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
    final formData = FormData.fromMap({
      'title': title,
      'description': description,
      'uploaderId': uploaderId,
      if (imageFile != null && imageFile.path != null)
        'image': await MultipartFile.fromFile(imageFile.path!,
            filename: imageFile.name),
      if (mainFile != null && mainFile.path != null)
        'mainFile': await MultipartFile.fromFile(
          mainFile.path!,
          filename: mainFile.name,
          contentType: MediaType('application', 'pdf'),
        ),
    });
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
}
