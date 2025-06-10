import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/quiz.dart';
import '../../quiz/views/edit_quiz_screen.dart'; // import EditQuizScreen

class QuizItem extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback? onTap;
  final bool isOwner; // thêm

  const QuizItem({
    super.key,
    required this.quiz,
    this.onTap,
    this.isOwner = false, // mặc định false
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.blue[200]!, // viền xanh nhạt
            width: 1.5,
          ),
        ),
        elevation: 1, // nhẹ cho đẹp
        color: Colors.white, // nền xanh dương rất nhạt
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon đại diện quiz
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white, // nền icon trắng
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue[300]!, // viền nhẹ cho icon
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.quiz,
                  size: 32,
                  color: Colors.blue[700], // icon xanh dương đậm
                ),
              ),

              const SizedBox(width: 12),

              // Nội dung quiz + nếu là owner thì hiện icon edit ở bên phải
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + Description + Date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tên quiz: to hơn, đậm
                              Text(
                                quiz.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900], // đậm hơn
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),

                              // Mô tả: nhỏ hơn tên quiz, màu xám
                              Text(
                                quiz.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),

                              // Ngày tạo: màu xám
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

                        // Nếu là owner → Icon edit
                        if (isOwner)
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditQuizScreen(quizId: quiz.id),
                                ),
                              ).then((result) {
                                // nếu bạn muốn xử lý khi quay về có thể thêm logic ở đây
                              });
                            },
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
    );
  }
}
