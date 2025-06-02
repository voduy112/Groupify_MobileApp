import 'package:flutter/material.dart';
import '../../../features/document_share/providers/document_share_provider.dart';
import '../../../models/document.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class ListDocumentItem extends StatelessWidget {
  const ListDocumentItem(
      {super.key, required this.documents, required this.userId});
  final List<Document> documents;
  final String userId;

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return Center(child: Text('Không có tài liệu nào'));
    }
    return SizedBox(
      height: 400,
      child: ListView.builder(
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final doc = documents[index];
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
              await provider.deleteDocument(doc.id ?? '', userId: userId);
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
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: Icon(Icons.image,
                            size: 32, color: Colors.grey[700]),
                      ),
              ),
              onTap: () {
                context.push('/home/document/${doc.id}');
              },
            ),
          );
        },
      ),
    );
  }
}
