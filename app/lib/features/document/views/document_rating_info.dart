import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';
import '../views/document_rating_screen.dart';

class DocumentRatingInfo extends StatefulWidget {
  final String documentId;

  const DocumentRatingInfo({Key? key, required this.documentId})
      : super(key: key);

  @override
  State<DocumentRatingInfo> createState() => _DocumentRatingInfoState();
}

class _DocumentRatingInfoState extends State<DocumentRatingInfo> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRating();
  }

  Future<void> fetchRating() async {
    await Provider.of<DocumentProvider>(context, listen: false)
        .fetchRatingOfDocument(widget.documentId);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DocumentProvider>(context);
    final averageRating = provider.averageRating;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DocumentRatingScreen(documentId: widget.documentId),
          ),
        );
      },
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                const Text("Đánh giá: ", style: TextStyle(fontSize: 24)),
                Text(
                  averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.star, color: Colors.orange, size: 20),
                const SizedBox(width: 10),
                const Icon(Icons.chevron_right),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
