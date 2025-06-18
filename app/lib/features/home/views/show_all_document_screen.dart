import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../features/document_share/providers/document_share_provider.dart';
import 'package:go_router/go_router.dart';

class ShowAllDocumentScreen extends StatefulWidget {
  @override
  _ShowAllDocumentScreenState createState() => _ShowAllDocumentScreenState();
}

class _ShowAllDocumentScreenState extends State<ShowAllDocumentScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  List<dynamic> _searchResults = [];

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

  void _onSearchChanged(String value) async {
    setState(() {
      _searchQuery = value;
      _isSearching = true;
    });
    if (value.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    try {
      final provider =
          Provider.of<DocumentShareProvider>(context, listen: false);
      final results = await provider.searchDocument(value);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final documentProvider = Provider.of<DocumentShareProvider>(context);
    final documents = documentProvider.documents;
    final showList = _searchQuery.isEmpty ? documents : _searchResults;
    return Scaffold(
      appBar: AppBar(
        title: Text('Tất cả tài liệu'),
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
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _isSearching
                ? Center(child: CircularProgressIndicator())
                : showList.isEmpty
                    ? Center(
                        child: Text(
                          'Không tìm thấy tài liệu',
                          style: TextStyle(fontSize: 20),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: showList.length +
                            (_searchQuery.isEmpty &&
                                    documentProvider.isFetchingMore
                                ? 1
                                : 0),
                        itemBuilder: (context, index) {
                          if (index < showList.length) {
                            final doc = showList[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  context.go('/home/document/${doc.id}',
                                      extra: {'from': 'show_all_document'});
                                },
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: doc.imgDocument ?? '',
                                          width: 100,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            width: 100,
                                            height: 120,
                                            color: Colors.grey.shade200,
                                            child: const Center(
                                              child: Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  color: Colors.grey,
                                                  size: 40),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            width: 100,
                                            height: 120,
                                            color: Colors.grey.shade200,
                                            child: const Center(
                                              child: Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  color: Colors.grey,
                                                  size: 35),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                doc.title ?? '',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF305973),
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                doc.description ?? '',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(
                                                      Icons.picture_as_pdf,
                                                      size: 18,
                                                      color: Colors.redAccent),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Xem chi tiết',
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
        height: 65,
        width: 65,
        margin: EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: () {
            context.go('/home/upload-document');
          },
          backgroundColor: Colors.white10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.white, width: 1),
          ),
          elevation: 8,
          child: Icon(
            Icons.add,
            size: 36,
            color: Colors.blue.shade500,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
