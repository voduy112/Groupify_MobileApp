import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../models/document.dart';
import '../../../services/api/dio_client.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class DocumentService {
  final Dio _dio;

  DocumentService() : _dio = DioClient.instance;

  Future<Document> getDocumentById(String documentId) async {
    try {
      final response = await _dio.get('/api/document/$documentId');
      if (response.statusCode == 200) {
        return Document.fromJson(response.data);
      } else {
        throw Exception(
            "Lỗi khi lấy thông tin tài liệu: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi getDocumentById: $e");
      rethrow;
    }
  }

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
}
