import 'package:flutter/material.dart';
import '../../../models/report.dart';
import '../services/report_service.dart';
import '../../document/services/document_service.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _service = ReportService();
  List<Report> _reports = [];
  bool _isLoading = false;

  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;

  Future<void> fetchAllReports() async {
    _isLoading = true;
    notifyListeners();

    _reports = await _service.getAllReports();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchReportsByDocumentId(String documentId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _reports = await _service.getReportsByDocumentId(documentId);
    } catch (e, stacktrace) {
      print('Lỗi khi fetch báo cáo cho tài liệu $documentId: $e');
      print(stacktrace);
      _reports = []; // Gán rỗng để tránh null
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createReport({
    required String reporterId,
    required String reason,
    required String documentId,
    String? action,
  }) async {
    final report = await _service.createReport(
      reporterId: reporterId,
      reason: reason,
      documentId: documentId,
      action: action,
    );

    if (report != null) {
      _reports.add(report);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateReport(String reportId,
      {String? reason, String? action}) async {
    final success =
        await _service.updateReport(reportId, reason: reason, action: action);
    if (success) {
      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        final updatedReport = await _service.getReportById(reportId);
        if (updatedReport != null) {
          _reports[index] = updatedReport;
          notifyListeners();
        }
      }
    }
    return success;
  }

  Future<bool> deleteReport(String reportId) async {
    final success = await _service.deleteReport(reportId);
    if (success) {
      _reports.removeWhere((r) => r.id == reportId);
      notifyListeners();
    }
    return success;
  }

  Future<Report?> getReportById(String reportId) async {
    return await _service.getReportById(reportId);
  }

  Future<Report?> getReportByDocumentIdAndReporterId(
      String documentId, String reporterId) async {
    return await _service.getReportByDocumentIdAndReporterId(
        documentId, reporterId);
  }

  Future<bool> checkOwner({
    required String documentId,
    required String userId,
    required DocumentService documentservice,
  }) async {
    try {
      final document = await documentservice.getDocumentById(documentId);
      if (document == null) return false;
      return document.uploaderId == userId;
    } catch (e) {
      print('Lỗi khi kiểm tra chủ sở hữu: $e');
      return false;
    }
  }
}
