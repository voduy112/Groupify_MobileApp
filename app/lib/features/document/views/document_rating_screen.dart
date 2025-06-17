import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';

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

  Widget _buildRatingStars(double rating) {
    return RatingBarIndicator(
      rating: rating,
      itemBuilder: (context, index) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      itemCount: 5,
      itemSize: 30.0,
      direction: Axis.horizontal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DocumentProvider>(context);
    final avg = provider.averageRating;
    final total = provider.totalRatings;
    final userRating = provider.userRatedValue;

    return Scaffold(
      appBar: AppBar(title: const Text('Đánh giá tài liệu')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            total == 0
                ? const Text(
                    'Chưa có đánh giá nào.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  )
                : Row(
                    children: [
                      _buildRatingStars(avg),
                      const SizedBox(width: 8),
                      Text('($total lượt đánh giá)'),
                    ],
                  ),
            const Divider(indent: 20, endIndent: 20),
            const SizedBox(height: 10),
            const Text(
              'Đánh giá của bạn:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 8),
            if (userRating != null)
              _buildRatingStars(userRating)
            else
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: _submitRating,
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
            CommentForm(documentId: widget.documentId),
          ],
        ),
      ),
    );
  }
}

// widget them binh luan
class CommentForm extends StatefulWidget {
  final String documentId;

  const CommentForm({super.key, required this.documentId});

  @override
  State<CommentForm> createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  Future<void> _sendComment() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isSending = true);

    final provider = Provider.of<DocumentProvider>(context, listen: false);
    final success =
        await provider.addComment(widget.documentId, _controller.text.trim());

    if (success) {
      _controller.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Gửi bình luận thất bại')),
      );
    }

    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextFormField(
        controller: _controller,
        keyboardType: TextInputType.multiline,
        maxLines: 2,
        minLines: 1,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          hintText: 'Nhập bình luận...',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendComment,
            color: Colors.blue,
          ),
        ),
        onFieldSubmitted: (_) => _sendComment(),
      ),
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
            final username = cmt['username'] ?? '';
            final content = cmt['content'];
            final createdAt = cmt['createdAt'] != null
                ? DateTime.tryParse(cmt['createdAt'])
                : null;
            final avatarUrl = cmt['avatar'];

            final timeDisplay = createdAt != null
                ? '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}'
                : '';

            // Thêm Dismissible ở đây
            return Dismissible(
              key: ValueKey(cmt['_id']),
              direction: provider.currentUserId == cmt['userId']
                  ? DismissDirection.endToStart
                  : DismissDirection.none,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Xác nhận xoá'),
                    content:
                        const Text('Bạn có chắc chắn muốn xoá bình luận này?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Huỷ'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.red.shade100),
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Colors.red.shade800),
                          side: MaterialStateProperty.all<BorderSide>(
                            BorderSide(color: Colors.red.shade800),
                          ),
                        ),
                        child: const Text('Xoá'),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (_) async {
                final success =
                    await provider.deleteComment(widget.documentId, cmt['_id']);
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xoá bình luận thất bại')),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null || avatarUrl.isEmpty
                          ? Text(
                              username.isNotEmpty
                                  ? username[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.black),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.titleSmall,
                              children: [
                                TextSpan(
                                    text: username,
                                    style: TextStyle(color: Colors.blue)),
                                if (provider.currentUserId ==
                                    cmt['userId']) ...[
                                  const TextSpan(
                                    text: ' · ',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: 'You',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(content ?? ''),
                          if (timeDisplay.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                timeDisplay,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
