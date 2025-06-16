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
}
