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
  bool _showSearchBar = false;

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
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        leading: _showSearchBar
            ? Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Container(
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.blue),
                      onPressed: () {
                        setState(() {
                          _showSearchBar = false;
                          _searchController.clear();
                          _searchQuery = '';
                          _searchResults = [];
                        });
                      },
                      tooltip: 'Thoát tìm kiếm',
                    ),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 12.0, bottom: 4),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.blue),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Quay lại',
                    ),
                  ),
                ),
              ),
        title: _showSearchBar
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm tài liệu...',
                    border: InputBorder.none,
                    fillColor: Colors.grey.shade100,
                    filled: true,
                  ),
                  onChanged: _onSearchChanged,
                ),
              )
            : const Text('Tất cả tài liệu'),
        actions: [
          if (!_showSearchBar)
            Container(
              margin: const EdgeInsets.only(right: 10.0, bottom: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.blue),
                tooltip: 'Tìm kiếm',
                onPressed: () {
                  setState(() {
                    _showSearchBar = true;
                  });
                },
              ),
            ),
        ],
      ),
      body: Column(
        children: [
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
                                  horizontal: 16, vertical: 10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  context.go('/home/document/${doc.id}',
                                      extra: {'from': 'show_all_document'});
                                },
                                child: Card(
                                  color: Colors.white,
                                  elevation: 8,
                                  shadowColor: Colors.black.withOpacity(1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: CachedNetworkImage(
                                            imageUrl: doc.imgDocument ?? '',
                                            width: 90,
                                            height: 110,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                              width: 90,
                                              height: 110,
                                              color: Colors.grey.shade200,
                                              child: const Center(
                                                child: Icon(
                                                    Icons
                                                        .image_not_supported_outlined,
                                                    color: Colors.grey,
                                                    size: 40),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              width: 90,
                                              height: 110,
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
                                        const SizedBox(width: 16),
                                        Expanded(
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
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Xem chi tiết',
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
      // floatingActionButton: Container(
      //   height: 65,
      //   width: 65,
      //   margin: EdgeInsets.only(bottom: 20),
      //   decoration: BoxDecoration(
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.black.withOpacity(0.25),
      //         blurRadius: 12,
      //         offset: Offset(0, 6),
      //       ),
      //     ],
      //     borderRadius: BorderRadius.circular(18),
      //   ),
      //   child: FloatingActionButton(
      //     onPressed: () {
      //       context.go('/home/upload-document');
      //     },
      //     backgroundColor: Colors.white,
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(18),
      //       side: BorderSide(color: Colors.white, width: 1),
      //     ),
      //     elevation: 8,
      //     child: Icon(
      //       Icons.add,
      //       size: 36,
      //       color: Colors.blue.shade500,
      //     ),
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
