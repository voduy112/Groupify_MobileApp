import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../document/providers/document_provider.dart';
import '../../../document/views/document_item.dart';
import '../../../document/views/document_detail_screen.dart';

class DocumentList extends StatelessWidget {
  final ScrollController scrollController;

  const DocumentList({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Consumer<DocumentProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text('Lỗi: ${provider.error}'));
        }

        if (provider.documents.isEmpty) {
          return const Center(child: Text('Không có tài liệu nào'));
        }

        return ListView.builder(
          controller: scrollController,
          itemCount: provider.documents.length,
          itemBuilder: (context, index) {
            final document = provider.documents[index];
            return DocumentItem(
              document: document,
              onTap: () {
                print('Tapped Document ID: ${document.id}');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        DocumentDetailScreen(documentId: document.id!),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
