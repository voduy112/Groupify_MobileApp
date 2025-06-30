import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';
import 'comment_card.dart';

class DocumentRatingScreen extends StatefulWidget {
  final String documentId;

  const DocumentRatingScreen({Key? key, required this.documentId})
      : super(key: key);

  @override
  State<DocumentRatingScreen> createState() => _DocumentRatingScreenState();
}

class _DocumentRatingScreenState extends State<DocumentRatingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<DocumentProvider>(context, listen: false);
      await provider.fetchRatingOfDocument(widget.documentId);
      //await provider.fetchComments(widget.documentId);
    });
  }

  void _submitRating(double value) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đánh giá'),
        content:
            Text('Bạn chắc chắn muốn đánh giá $value sao cho tài liệu này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final provider = Provider.of<DocumentProvider>(context, listen: false);
    final success = await provider.rateDocument(widget.documentId, value);
    if (success) {
      await provider.fetchRatingOfDocument(widget.documentId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đánh giá thành công')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Gửi đánh giá thất bại')),
      );
    }
  }

  Widget _buildRatingSummary(
      Map<int, int> ratingCounts, int total, double average) {
    double getPercent(int count) => total == 0 ? 0 : count / total;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Đánh giá và bình luận ($total)',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: List.generate(5, (index) {
                      final star = 5 - index;
                      final count = ratingCounts[star] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text('$star', style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: getPercent(count),
                                minHeight: 8,
                                backgroundColor: Colors.grey[300],
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text('($count)',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Text(average.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange)),
                    const Icon(Icons.star, color: Colors.amber, size: 28),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DocumentProvider>(context);
    final avg = provider.averageRating;
    final userRating = provider.userRatedValue;
    final total = provider.totalRatings;
    print('⭐ TOTAL RATING: $total');
    return Scaffold(
      appBar: AppBar(title: const Text('Đánh giá tài liệu')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            total > 0
                ? _buildRatingSummary(provider.ratingCounts, total, avg)
                : const Text(
                    'Chưa có đánh giá nào.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
            const Divider(indent: 20, endIndent: 20),
            const SizedBox(height: 10),
            const Text(
              'Bình luận:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: CommentList(documentId: widget.documentId),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: provider.userRatedValue == null
          ? FloatingActionButton(
              onPressed: () {
                showRatingCommentDialog(context, widget.documentId);
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
              shape: const CircleBorder(), // Bo tròn
            )
          : null,
    );
  }
}

// widget lay danh sach binh luan
class CommentList extends StatefulWidget {
  final String documentId;

  const CommentList({super.key, required this.documentId});

  @override
  State<CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  bool _isLoading = false;
  int _visibleCount = 10; // <-- CHỈ HIỂN THỊ 10 BÌNH LUẬN ĐẦU TIÊN

  @override
  void initState() {
    super.initState();
    _loadInitialComments();
  }

  Future<void> _loadInitialComments() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<DocumentProvider>(context, listen: false);
    await provider.fetchComments(widget.documentId, skip: 0, limit: 10);
    setState(() => _isLoading = false);
  }

  Future<void> _loadMoreComments() async {
    final provider = Provider.of<DocumentProvider>(context, listen: false);
    if (_isLoading || !provider.hasMoreComments(widget.documentId)) return;

    setState(() => _isLoading = true);

    final skip = provider.getLoadedCommentCount(widget.documentId);
    await provider.fetchComments(widget.documentId, skip: skip, limit: 10);

    setState(() {
      _visibleCount += 10;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DocumentProvider>(context);
    final allComments = provider.comments[widget.documentId] ?? [];
    final visibleComments = allComments.take(_visibleCount).toList();
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleComments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final cmt = visibleComments[index];
            return CommentCard(
              comment: cmt,
              currentUserId: provider.currentUserId,
              onDelete: () async {
                return await provider.deleteComment(
                    widget.documentId, cmt['_id']);
              },
            );
          },
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        if (!_isLoading &&
            provider.hasMoreComments(widget.documentId) &&
            _visibleCount < (provider.getTotalCommentCount(widget.documentId)))
          TextButton(
            onPressed: _loadMoreComments,
            child: const Text('Xem thêm bình luận...'),
          ),
      ],
    );
  }
}

void showRatingCommentDialog(BuildContext context, String documentId) {
  double rating = 0;
  final TextEditingController controller = TextEditingController();
  final provider = Provider.of<DocumentProvider>(context, listen: false);
  bool isLoading = false;

  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Đánh giá & Bình luận'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Chọn số sao:"),
                  const SizedBox(height: 8),
                  RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    itemCount: 5,
                    itemSize: 30,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (value) {
                      setState(() => rating = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Nhập bình luận...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Huỷ"),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (rating == 0 || controller.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Vui lòng nhập bình luận và số sao")),
                          );
                          return;
                        }

                        setState(() => isLoading = true);

                        final ok1 =
                            await provider.rateDocument(documentId, rating);
                        final ok2 = await provider.addComment(
                          documentId,
                          controller.text.trim(),
                          rating: rating,
                        );

                        setState(() => isLoading = false);

                        if (ok1 && ok2 && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Gửi đánh giá/bình luận thành công")),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Gửi đánh giá/bình luận thất bại")),
                          );
                        }
                      },
                child: const Text("Gửi"),
              ),
            ],
          );
        },
      );
    },
  );
}
