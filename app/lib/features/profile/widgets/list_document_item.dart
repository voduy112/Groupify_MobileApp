import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../features/document_share/providers/document_share_provider.dart';
import '../../../models/document.dart';
import '../../../models/report.dart';
import '../../report/providers/report_provider.dart';

class ListDocumentItem extends StatefulWidget {
  const ListDocumentItem({
    super.key,
    required this.documents,
    required this.userId,
    required this.currentUserId,
  });

  final List<Document> documents;
  final String userId;
  final String currentUserId;

  @override
  State<ListDocumentItem> createState() => _ListDocumentItemState();
}

class _ListDocumentItemState extends State<ListDocumentItem> {
  final Map<String, Future<List<Report>>> _reportFutures = {};
  final Set<String> _seenReports = {}; // Đã xem báo cáo

  void _showReportSummaryDialog(BuildContext context, List<Report> reports,
      String docTitle, String docId) {
    _seenReports.add(docId);
    setState(() {});

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Báo cáo cho "$docTitle"'),
          backgroundColor: Colors.white,
          content: reports.isEmpty
              ? const Text("Không có báo cáo nào.")
              : SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("📌 Tổng số báo cáo: ${reports.length}"),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: reports.length,
                          itemBuilder: (context, index) {
                            final report = reports[index];
                            return ListTile(
                              leading:
                                  const Icon(Icons.flag, color: Colors.red),
                              title: Text(report.reason ?? 'Không rõ lý do'),
                              subtitle: Text(
                                "⏱️ ${DateFormat('dd/MM/yyyy – HH:mm').format(DateTime.parse(report.createDate!).toLocal())}",
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Đóng"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleMenuAction(
      BuildContext context, String value, Document doc) async {
    final docId = doc.id!;
    switch (value) {
      case 'edit':
        context.go('/profile/document/edit/$docId', extra: doc);
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text('Bạn có chắc muốn xóa "${doc.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Xóa'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          final provider =
              Provider.of<DocumentShareProvider>(context, listen: false);
          await provider.deleteDocument(docId, userId: widget.userId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã xóa tài liệu "${doc.title}"')),
          );
        }
        break;
      case 'report':
        final rawReports = await _reportFutures[docId];
        final reports = rawReports is List<Report> ? rawReports : <Report>[];
        _showReportSummaryDialog(context, reports, doc.title ?? '', docId);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.documents.isEmpty) {
      return const Center(child: Text('Không có tài liệu nào'));
    }

    return SizedBox(
      height: 400,
      child: ListView.builder(
        itemCount: widget.documents.length,
        itemBuilder: (context, index) {
          final doc = widget.documents[index];
          final docId = doc.id!;
          _reportFutures[docId] = Provider.of<ReportProvider>(context,
                  listen: false)
              .fetchReportsByDocumentId(docId)
              .then((_) =>
                  Provider.of<ReportProvider>(context, listen: false).reports);

          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            elevation: 3,
            shadowColor: Colors.blue[200],
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        doc.imgDocument != null && doc.imgDocument!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: doc.imgDocument!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.grey,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: Icon(Icons.image,
                                    size: 32, color: Colors.grey[700]),
                              ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        context.push('/home/document/$docId', extra: doc);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.title ?? 'Tên tài liệu',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Mô tả: ${doc.description ?? 'Không xác định'}',
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.currentUserId == widget.userId)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        _handleMenuAction(context, value, doc);
                      },
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Chỉnh sửa'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Xoá'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'report',
                          child: Text('Xem báo cáo'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
