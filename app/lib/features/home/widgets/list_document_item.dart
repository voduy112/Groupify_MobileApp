import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/document_share/providers/document_share_provider.dart';
import 'package:go_router/go_router.dart';

class ListDocumentItem extends StatefulWidget {
  const ListDocumentItem({super.key});

  @override
  State<ListDocumentItem> createState() => _ListDocumentItemState();
}

class _ListDocumentItemState extends State<ListDocumentItem> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<DocumentShareProvider>(context, listen: false)
            .fetchDocuments());
  }

  @override
  Widget build(BuildContext context) {
    final documents = context.watch<DocumentShareProvider>().documents;
    print("documents: $documents");
    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
        ),
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final document = documents[index];
          return GestureDetector(
            onTap: () {
              context.go('/home/document/${document.id}');
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      document.imgDocument ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  document.title ?? 'No title',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
