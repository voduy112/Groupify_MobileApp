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

  int? totalPages;
  int currentPage = 0;
  PDFViewController? pdfViewController;
  final pageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<DocumentProvider>(context, listen: false);
      await provider.fetchDocumentById(widget.documentId);

      final fileUrl = provider.selectedDocument?.mainFile;
      if (fileUrl != null && fileUrl.isNotEmpty) {
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

  void goToPage() {
    final input = int.tryParse(pageController.text);
    if (input != null &&
        input > 0 &&
        totalPages != null &&
        input <= totalPages!) {
      pdfViewController?.setPage(input - 1);
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Số trang không hợp lệ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DocumentProvider>(context);
    final document = provider.selectedDocument;

    return Scaffold(
      appBar: AppBar(
        title: Text(document?.title ?? 'Chi tiết tài liệu'),
        actions: [
          if (totalPages != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  '$currentPage/$totalPages',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : document == null
              ? const Center(child: Text('Không tìm thấy tài liệu'))
              : loadError != null
                  ? Center(child: Text(loadError!))
                  : localPath == null
                      ? const Center(child: Text('Đang tải PDF...'))
                      : Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  PDFView(
                                    filePath: localPath!,
                                    enableSwipe: true,
                                    swipeHorizontal: true,
                                    autoSpacing: true,
                                    pageFling: true,
                                    onRender: (pages) {
                                      setState(() {
                                        totalPages = pages;
                                      });
                                    },
                                    onViewCreated: (controller) {
                                      pdfViewController = controller;
                                    },
                                    onPageChanged: (page, total) {
                                      setState(() {
                                        currentPage = (page ?? 0) + 1;
                                        totalPages = total;
                                      });
                                    },
                                    onError: (error) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Lỗi khi hiển thị PDF: $error')));
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: pageController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Tới trang',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: goToPage,
                                    child: Text('Đi'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
