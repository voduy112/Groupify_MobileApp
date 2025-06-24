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
  });

  final List<Document> documents;
  final String userId;

  @override
  State<ListDocumentItem> createState() => _ListDocumentItemState();
}

class _ListDocumentItemState extends State<ListDocumentItem> {
  final Map<String, Future<List<Report>>> _reportFutures = {};
  final Set<String> _seenReports = {}; // Đã xem báo cáo

  void _showReportSummaryDialog(BuildContext context, List<Report> reports,
      String docTitle, String docId) {
    _seenReports.add(docId); // Đánh dấu đã xem
    setState(() {}); // Cập nhật UI

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

          return Dismissible(
            key: ValueKey(docId),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) async {
              final provider =
                  Provider.of<DocumentShareProvider>(context, listen: false);
              await provider.deleteDocument(docId, userId: widget.userId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa tài liệu "${doc.title}"')),
              );
            },
            child: ListTile(
              title: Text(doc.title ?? ''),
              subtitle: Text(doc.description ?? ''),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: doc.imgDocument != null && doc.imgDocument!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: doc.imgDocument!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 120,
                          width: 100,
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
                          height: 120,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                              size: 35,
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Sửa',
                    onPressed: () {
                      context.go('/profile/document/edit/$docId', extra: doc);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Xóa',
                    onPressed: () async {
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
                        final provider = Provider.of<DocumentShareProvider>(
                            context,
                            listen: false);
                        await provider.deleteDocument(docId,
                            userId: widget.userId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Đã xóa tài liệu "${doc.title}"')),
                        );
                      }
                    },
                  ),
                  FutureBuilder<List<Report>>(
                    future: _reportFutures[docId],
                    builder: (context, snapshot) {
                      final hasReports =
                          snapshot.connectionState == ConnectionState.done &&
                              snapshot.hasData &&
                              snapshot.data!.isNotEmpty;

                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.flag,
                                color: Colors.orangeAccent),
                            tooltip: 'Xem báo cáo',
                            onPressed: () {
                              if (snapshot.hasData) {
                                _showReportSummaryDialog(context,
                                    snapshot.data!, doc.title ?? '', docId);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Đang tải dữ liệu báo cáo...")),
                                );
                              }
                            },
                          ),
                          // if (hasReports && !_seenReports.contains(docId))
                          //   const Positioned(
                          //     right: 6,
                          //     top: 6,
                          //     child: CircleAvatar(
                          //       radius: 5,
                          //       backgroundColor: Colors.red,
                          //     ),
                          //   ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              onTap: () {
                context.push('/home/document/$docId', extra: doc);
              },
            ),
          );
        },
      ),
    );
  }
}
