import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/quiz.dart';

class QuizItem extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback? onTap;

  const QuizItem({
    super.key,
    required this.quiz,
    this.onTap,
  });

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon đại diện quiz
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.quiz, size: 32, color: Colors.blue),
              ),

              const SizedBox(width: 12),

              // Nội dung quiz
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quiz.description,
                      style: const TextStyle(color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ngày tạo: ${formatDate(quiz.createdAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
