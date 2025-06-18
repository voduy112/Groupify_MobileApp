import 'package:dio/dio.dart';
import '../../../models/report.dart';
import '../../../services/api/dio_client.dart';

class ReportService {
  final Dio _dio;

  ReportService() : _dio = DioClient.instance;

  Future<Report?> createReport({
    required String reporterId,
    required String reason,
    required String documentId,
    String? action,
  }) async {
    try {
      final response = await _dio.post('/api/report/', data: {
        'reporterId': reporterId,
        'reason': reason,
        'documentId': documentId,
        if (action != null) 'action': action,
      });

      return Report.fromJson(response.data['report']);
    } on DioException catch (e) {
      print('Lỗi khi tạo báo cáo: $e');
      return null;
    } catch (e) {
      print('Lỗi không xác định khi tạo báo cáo: $e');
      return null;
    }
  }

  Future<bool> updateReport(String id, {String? reason, String? action}) async {
    try {
      final response = await _dio.put('/api/report/$id', data: {
        if (reason != null) 'reason': reason,
        if (action != null) 'action': action,
      });
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi khi cập nhật báo cáo: $e');
      return false;
    }
  }

  Future<bool> deleteReport(String id) async {
    try {
      final response = await _dio.delete('/api/report/$id');
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi khi xoá báo cáo: $e');
      return false;
    }
  }

  Future<Report?> getReportById(String id) async {
    try {
      final response = await _dio.get('/api/report/$id');
      return Report.fromJson(response.data);
    } catch (e) {
      print('Lỗi khi lấy báo cáo theo ID: $e');
      return null;
    }
  }

  Future<Report?> getReportByDocumentIdAndReporterId(
      String documentId, String reporterId) async {
    try {
      final response = await _dio
          .get('/api/report/document/$documentId/reporter/$reporterId');
      if (response.statusCode == 200 && response.data != null) {
        return Report.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy báo cáo theo document và người dùng: $e');
      return null;
    }
  }

  Future<List<Report>> getAllReports() async {
    try {
      final response = await _dio.get('/api/report/');
      final List data = response.data;
      return data.map((json) => Report.fromJson(json)).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách báo cáo: $e');
      return [];
    }
  }

  Future<List<Report>> getReportsByDocumentId(String documentId) async {
    try {
      final response = await _dio.get('/api/report/document/$documentId');
      final List data = response.data;
      return data.map((json) => Report.fromJson(json)).toList();
    } catch (e) {
      print('Lỗi khi lấy báo cáo theo documentId: $e');
      return [];
    }
  }
}
