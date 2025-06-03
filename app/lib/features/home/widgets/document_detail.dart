import 'package:flutter/material.dart';
import '../../../models/document.dart';
import '../../../features/document/views/document_detail_screen.dart';
import '../../../features/document/services/document_service.dart';
import '../../../features/document/providers/document_provider.dart';
import 'package:provider/provider.dart';

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
      appBar: AppBar(title: Text(document!.title ?? 'Chi tiết tài liệu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (document!.imgDocument != null &&
                document!.imgDocument!.isNotEmpty)
              Center(
                child: Image.network(
                  document!.imgDocument!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              document!.title ?? 'Không có tiêu đề',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              document!.description ?? 'Không có mô tả',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
