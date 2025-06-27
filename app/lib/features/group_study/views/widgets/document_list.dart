import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../document/providers/document_provider.dart';
import '../../../document/views/document_item.dart';
import '../../../document/views/document_detail_screen.dart';
import '../../../document/views/upload_document_screen.dart';
import '../../../document/views/edit_document_screen.dart';

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
                              currentUserId: currentUserId,
                              groupOwnerId: groupOwnerId,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DocumentDetailScreenView(
                                        documentId: document.id!),
                                  ),
                                );
                              },
                              onEdit: () async {
                                final result = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditDocumentScreen(document: document),
                                  ),
                                );

                                if (result == true) {
                                  // Nếu chỉnh sửa thành công => reload danh sách
                                  context
                                      .read<DocumentProvider>()
                                      .fetchDocumentsByGroupId(groupId);
                                }
                              }, 
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Xác nhận xoá'),
                                    content: const Text(
                                        'Bạn có chắc chắn muốn xoá tài liệu này?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Huỷ')),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text('Xoá')),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await context
                                      .read<DocumentProvider>()
                                      .deleteDocumentById(document.id!);
                                  context
                                      .read<DocumentProvider>()
                                      .fetchDocumentsByGroupId(groupId);
                                }
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
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Colors.white12, width: 2),
                    ),
                    elevation: 8,
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
                  child: Icon(
                    Icons.add,
                    size: 27,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
