import 'package:flutter/material.dart';
import '../../../features/document_share/providers/document_share_provider.dart';
import '../../../models/document.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class ListDocumentItem extends StatefulWidget {
  const ListDocumentItem(
      {super.key, required this.documents, required this.userId});
  final List<Document> documents;
  final String userId;

  @override
  State<ListDocumentItem> createState() => _ListDocumentItemState();
}

class _ListDocumentItemState extends State<ListDocumentItem> {
  int? editingIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.documents.isEmpty) {
      return Center(child: Text('Không có tài liệu nào'));
    }
    return SizedBox(
      height: 400,
      child: ListView.builder(
        itemCount: widget.documents.length,
        itemBuilder: (context, index) {
          final doc = widget.documents[index];
          return Dismissible(
            key: ValueKey(doc.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) async {
              final provider =
                  Provider.of<DocumentShareProvider>(context, listen: false);
              await provider.deleteDocument(doc.id ?? '',
                  userId: widget.userId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa tài liệu "${doc.title}"')),
              );
            },
            child: Builder(
              builder: (tileContext) => ListTile(
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
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: Icon(Icons.image,
                              size: 32, color: Colors.grey[700]),
                        ),
                ),
                trailing: editingIndex == index
                    ? IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          setState(() {
                            editingIndex = null;
                          });
                          context.go('/profile/document/edit/${doc.id}',
                              extra: doc);
                        },
                        tooltip: 'Sửa document',
                      )
                    : null,
                onTap: () {
                  context.push('/home/document/${doc.id}', extra: doc);
                },
                onLongPress: () async {
                  final RenderBox tileBox =
                      tileContext.findRenderObject() as RenderBox;
                  final Offset tilePosition =
                      tileBox.localToGlobal(Offset.zero);

                  final result = await showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      tilePosition.dx,
                      tilePosition.dy,
                      tilePosition.dx,
                      tilePosition.dy,
                    ),
                    items: [
                      PopupMenuItem(
                        value: 'edit',
                        onTap: () {
                          context.go('/profile/document/edit/${doc.id}',
                              extra: doc);
                        },
                        child: Text('Sửa document'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        onTap: () {
                          final provider = Provider.of<DocumentShareProvider>(
                              context,
                              listen: false);
                          provider.deleteDocument(doc.id ?? '',
                              userId: widget.userId);
                        },
                        child: Text('Xóa document'),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
