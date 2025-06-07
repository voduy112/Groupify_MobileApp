import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../document/providers/document_provider.dart';
import '../../../document/views/document_item.dart';
import '../../../document/views/document_detail_screen.dart';
import '../../../document/views/upload_document_screen.dart';

class DocumentList extends StatelessWidget {
  final ScrollController scrollController;
  final String groupId;
  final String currentUserId;
  final String groupOwnerId;

  const DocumentList({
    super.key,
    required this.scrollController,
    required this.groupId,
    required this.currentUserId,
    required this.groupOwnerId,
  });

  bool get isOwner => currentUserId == groupOwnerId;

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

        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: provider.documents.isEmpty
                      ? const Center(child: Text('Không có tài liệu nào'))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: provider.documents.length,
                          itemBuilder: (context, index) {
                            final document = provider.documents[index];
                            return DocumentItem(
                              document: document,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DocumentDetailScreenView(
                                      documentId: document.id!,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
            if (isOwner)
              Positioned(
                bottom: 16,
                right: 16,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(204, 22, 94, 166),
                    padding: const EdgeInsets.all(16),
                    shape: const CircleBorder(), // hình tròn
                    elevation: 4,
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (_) => UploadDocumentScreen(groupId: groupId),
                      ),
                    )
                        .then((result) {
                      if (result == true) {
                        context
                            .read<DocumentProvider>()
                            .fetchDocumentsByGroupId(groupId);
                      }
                    });
                  },
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
          ],
        );
      },
    );
  }
}
