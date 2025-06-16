import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/document_share/providers/document_share_provider.dart';
import 'package:go_router/go_router.dart';

class ShowAllDocumentScreen extends StatefulWidget {
  @override
  _ShowAllDocumentScreenState createState() => _ShowAllDocumentScreenState();
}

class _ShowAllDocumentScreenState extends State<ShowAllDocumentScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<DocumentShareProvider>(context, listen: false);
    provider.fetchDocuments(page: 1);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final provider = Provider.of<DocumentShareProvider>(context, listen: false);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !provider.isFetchingMore &&
        provider.currentPage < provider.totalPages) {
      provider.fetchMoreDocuments();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final documentProvider = Provider.of<DocumentShareProvider>(context);
    final filteredDocuments = documentProvider.documents
        .where((doc) =>
            (doc.title != null &&
                doc.title!
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase())) ||
            (doc.description != null &&
                doc.description!
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase())))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('All Documents'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm tài liệu...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: filteredDocuments.isEmpty
                ? Center(child: Text('No documents found'))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: filteredDocuments.length +
                        (documentProvider.isFetchingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < filteredDocuments.length) {
                        return ListTile(
                          title: Text(filteredDocuments[index].title ?? ''),
                          subtitle:
                              Text(filteredDocuments[index].description ?? ''),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              filteredDocuments[index].imgDocument ?? '',
                              fit: BoxFit.cover,
                              height: 100,
                              width: 100,
                            ),
                          ),
                          onTap: () {
                            context.go(
                                '/home/document/${filteredDocuments[index].id}',
                                extra: {'from': 'show_all_document'});
                          },
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: () {
            context.go('/home/upload-document');
          },
          child: Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
