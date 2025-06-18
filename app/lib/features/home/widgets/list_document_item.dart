import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/document_share/providers/document_share_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../document/services/document_service.dart';

class ListDocumentItem extends StatefulWidget {
  const ListDocumentItem({super.key});

  @override
  State<ListDocumentItem> createState() => _ListDocumentItemState();
}

class _ListDocumentItemState extends State<ListDocumentItem> {
  @override
  Widget build(BuildContext context) {
    final documents = context.watch<DocumentShareProvider>().documents;

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: (documents.length > 6 ? 6 : documents.length) + 1,
        itemBuilder: (context, index) {
          if (index == (documents.length > 6 ? 6 : documents.length)) {
            return Container(
              width: 120,
              margin: const EdgeInsets.only(right: 16),
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/home/show-all-document');
                },
                child: const Text('Xem thêm...'),
              ),
            );
          }

          final document = documents[index];
          return GestureDetector(
            onTap: () {
              context.go('/home/document/${document.id}');
            },
            child: Container(
              width: 170,
              margin: const EdgeInsets.only(right: 16),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Khung nội dung chính
                  Container(
                    height: 140,
                    width: 180,
                    margin: const EdgeInsets.only(top: 40),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 80),
                        Text(
                          document.title ?? 'No title',
                          style: const TextStyle(
                            fontSize: 18,
                            overflow: TextOverflow.ellipsis,
                            color: Color(0xFF305973),
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),

                  // Ảnh nổi
                  Positioned(
                    top: 0,
                    left: 20,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: document.imgDocument ?? '',
                        height: 120,
                        width: 100,
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
                      ),
                    ),
                  ),

                  // Icon tải
                  Positioned(
                    top: 45,
                    right: 5,
                    child: IconButton(
                      icon: const Icon(Icons.download_rounded, size: 20),
                      color: Colors.blue,
                      onPressed: () {
                        DocumentService().downloadPdf(context, document);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
