import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';

import '../../../models/document.dart';
import '../providers/document_provider.dart';

class DocumentDetailScreenView extends StatefulWidget {
  final String documentId;

  const DocumentDetailScreenView({Key? key, required this.documentId})
      : super(key: key);

  @override
  State<DocumentDetailScreenView> createState() =>
      _DocumentDetailScreenViewState();
}

class _DocumentDetailScreenViewState extends State<DocumentDetailScreenView> {
  String? localPath;
  String? loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<DocumentProvider>(context, listen: false);
      await provider.fetchDocumentById(widget.documentId);

      final fileUrl = provider.selectedDocument?.mainFile;
      if (fileUrl != null && fileUrl.isNotEmpty) {
        print(fileUrl);
        try {
          final response = await http.get(
            Uri.parse(fileUrl),
            headers: {
              'Accept': 'application/pdf',
            },
          );
          if (response.statusCode == 200) {
            final dir = await getTemporaryDirectory();
            final file = File('${dir.path}/temp_doc.pdf');
            await file.writeAsBytes(response.bodyBytes);
            setState(() {
              localPath = file.path;
            });
          } else {
            setState(() {
              loadError =
                  "Tải PDF thất bại (${response.statusCode}): ${response.body}";
            });
          }
        } catch (e) {
          setState(() {
            loadError = "Lỗi khi tải PDF: $e";
          });
        }
      } else {
        setState(() {
          loadError = "File PDF không tồn tại.";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DocumentProvider>(context);
    final document = provider.selectedDocument;

    return Scaffold(
      appBar: AppBar(title: Text(document?.title ?? 'Chi tiết tài liệu')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : document == null
              ? const Center(child: Text('Không tìm thấy tài liệu'))
              : loadError != null
                  ? Center(child: Text(loadError!))
                  : localPath == null
                      ? const Center(child: Text('Đang tải PDF...'))
                      : PDFView(
                          filePath: localPath!,
                          enableSwipe: true,
                          swipeHorizontal: true,
                          autoSpacing: true,
                          pageFling: true,
                          onError: (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Lỗi khi hiển thị PDF: $error')),
                            );
                          },
                        ),
    );
  }
}
