import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../models/document.dart';
import '../../../features/document/views/document_detail_screen.dart';
import '../../../features/document/services/document_service.dart';
import '../../../features/document/providers/document_provider.dart';
import 'package:provider/provider.dart';

import '../../document/views/document_rating_info.dart';
import '../../report/providers/report_provider.dart';
import '../../authentication/providers/auth_provider.dart';

class DocumentDetailScreen extends StatefulWidget {
  final String documentId;
  const DocumentDetailScreen({super.key, required this.documentId});

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  Document? document;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDocument();
  }

  Future<void> fetchDocument() async {
    final provider = Provider.of<DocumentProvider>(context, listen: false);
    await provider.fetchDocumentById(widget.documentId);
    document = provider.selectedDocument;
    setState(() {
      isLoading = false;
    });
  }

  bool _canWithdrawReport(String createDateStr) {
    final reportTime = DateTime.parse(createDateStr).toLocal();
    final now = DateTime.now();
    final difference = now.difference(reportTime);
    return difference.inHours <= 24;
  }

  void _showReportDialog() async {
    final TextEditingController reasonController = TextEditingController();
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final documentService = DocumentService();

    final userId = authProvider.user?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập để báo cáo')),
      );
      return;
    }

    // ✅ Kiểm tra nếu người dùng là chủ sở hữu tài liệu => không cho báo cáo
    final isOwner = await reportProvider.checkOwner(
      documentId: document!.id!,
      userId: userId,
      documentservice: documentService,
    );

    if (isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bạn không thể báo cáo tài liệu của chính mình')),
      );
      return;
    }

    // 🔍 Kiểm tra người dùng đã báo cáo tài liệu này chưa
    final existingReport =
        await reportProvider.getReportByDocumentIdAndReporterId(
      document!.id!,
      userId,
    );

    if (existingReport != null) {
      // Đã báo cáo -> hiển thị chi tiết + tuỳ chọn thu hồi nếu còn trong thời gian
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Bạn đã báo cáo tài liệu này'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📝 Lý do: ${existingReport.reason}"),
                const SizedBox(height: 8),
                Text(
                  "📅 Thời gian: ${DateFormat('dd/MM/yyyy – HH:mm').format(DateTime.parse(existingReport.createDate!).toLocal())}",
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
              if (_canWithdrawReport(existingReport.createDate!))
                TextButton(
                  onPressed: () async {
                    final success =
                        await reportProvider.deleteReport(existingReport.id!);
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Thu hồi báo cáo thành công'
                            : 'Thu hồi thất bại'),
                      ),
                    );
                  },
                  child: const Text('Thu hồi báo cáo',
                      style: TextStyle(color: Colors.red)),
                ),
            ],
          );
        },
      );
      return;
    }

    // Nếu chưa báo cáo và không phải chủ sở hữu => hiển thị form
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Báo cáo tài liệu'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(hintText: 'Nhập lý do báo cáo'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await reportProvider.createReport(
                  reporterId: userId,
                  reason: reasonController.text.trim(),
                  documentId: document!.id!,
                );

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Báo cáo đã được gửi'
                        : 'Gửi báo cáo thất bại'),
                  ),
                );
              },
              child: const Text('Gửi'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết tài liệu')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (document == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết tài liệu')),
        body: const Center(child: Text('Không tìm thấy tài liệu')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(document!.title ?? 'Chi tiết tài liệu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.report, color: Colors.red),
            tooltip: 'Báo cáo',
            onPressed: () {
              _showReportDialog();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (document!.imgDocument != null &&
                document!.imgDocument!.isNotEmpty)
              Center(
                child: CachedNetworkImage(
                  imageUrl: document!.imgDocument!,
                  height: 200,
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
                    height: double.infinity,
                    width: double.infinity,
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
                ),
              ),
            const SizedBox(height: 16),
            Row(children: [
              const Icon(
                Icons.title_sharp,
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ('Tiêu đề: ' '${document!.title}') ?? 'Không có tiêu đề',
                  style: TextStyle(fontSize: 24),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              )
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(
                Icons.description_outlined,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ('Tiêu đề: ' '${document!.description}') ?? '',
                  style: TextStyle(fontSize: 24),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              )
            ]),
            const SizedBox(height: 8),
            DocumentRatingInfo(documentId: widget.documentId),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DocumentDetailScreenView(
                                documentId: document!.id!),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text("READ")),
                  ElevatedButton(
                    onPressed: () {
                      DocumentService().downloadPdf(context, document!);
                    },
                    child: Text("DOWNLOAD"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
