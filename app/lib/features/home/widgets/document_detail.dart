import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/document_share/providers/document_share_provider.dart';
import '../../../models/document.dart';
import '../../../features/document/views/document_detail_screen.dart';

class DocumentDetailScreen extends StatelessWidget {
  final String documentId;
  const DocumentDetailScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    final documents = context.watch<DocumentShareProvider>().documents;
    final Document? document = documents.firstWhere(
      (doc) => doc.id == documentId,
      orElse: () => Document(),
    );

    if (document == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết tài liệu')),
        body: const Center(child: Text('Không tìm thấy tài liệu')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(document.title ?? 'Chi tiết tài liệu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (document.imgDocument != null &&
                document.imgDocument!.isNotEmpty)
              Center(
                child: Image.network(
                  document.imgDocument!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              document.title ?? 'Không có tiêu đề',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              document.description ?? 'Không có mô tả',
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
                                documentId: document.id!),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text("READ")),
                  ElevatedButton(onPressed: () {}, child: Text("DOWNLOAD")),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
