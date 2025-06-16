import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../quiz/providers/quiz_provider.dart';
import '../../../quiz/views/quiz_item.dart';
import '../../../quiz/views/result_quiz_screen.dart';
import '../../../quiz/views/create_quiz_screen.dart'; // import CreateQuizScreen
import '../../../authentication/providers/auth_provider.dart';

class QuizList extends StatelessWidget {
  final ScrollController scrollController;
  final String groupId;
  final String currentUserId;
  final String groupOwnerId;

  const QuizList({
    super.key,
    required this.scrollController,
    required this.groupId,
    required this.currentUserId,
    required this.groupOwnerId,
  });

  bool get isOwner => currentUserId == groupOwnerId;

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

        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: provider.quizzes.isEmpty
                      ? const Center(child: Text('Không có bộ câu hỏi nào'))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: provider.quizzes.length,
                          itemBuilder: (context, index) {
                            final quiz = provider.quizzes[index];
                            return QuizItem(
                              quiz: quiz,
                              isOwner: isOwner,
                              onTap: () {
                                final authProvider = Provider.of<AuthProvider>(
                                    context,
                                    listen: false);
                                final userId = authProvider.user?.id;

                                if (userId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Không tìm thấy người dùng')),
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
                        ),
                ),
              ],
            ),
            if (isOwner)
              Positioned(
                bottom: 16,
                right: 16,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(204, 22, 94, 166),
                    padding: const EdgeInsets.all(16),
                    shape: const CircleBorder(),
                    elevation: 4,
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (_) => CreateQuizScreen(groupId: groupId),
                      ),
                    )
                        .then((result) {
                      if (result == true) {
                        context
                            .read<QuizProvider>()
                            .fetchQuizzesByGroupId(groupId);
                      }
                    });
                  },
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
          ],
        );
      },
    );
  }
}
