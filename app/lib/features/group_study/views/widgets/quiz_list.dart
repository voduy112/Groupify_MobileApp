import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../quiz/providers/quiz_provider.dart';
import '../../../quiz/views/quiz_item.dart';
import '../../../quiz/views/quiz_detail_screen.dart';
import '../../../quiz/views/result_quiz_screen.dart';
import '../../../authentication/providers/auth_provider.dart';

class QuizList extends StatelessWidget {
  final ScrollController scrollController;

  const QuizList({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text('Lỗi: ${provider.error}'));
        }

        if (provider.quizzes.isEmpty) {
          return const Center(child: Text('Không có bộ câu hỏi nào'));
        }

        return ListView.builder(
          controller: scrollController,
          itemCount: provider.quizzes.length,
          itemBuilder: (context, index) {
            final quiz = provider.quizzes[index];
            return QuizItem(
              quiz: quiz,
              onTap: () {
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                final userId = authProvider.user?.id;

                if (userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Không tìm thấy người dùng')),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultQuizScreen(
                      quizId: quiz.id,
                      userId: userId,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
