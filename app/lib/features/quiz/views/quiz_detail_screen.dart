import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/quiz.dart';
import '../providers/quiz_provider.dart';

class QuizDetailScreen extends StatefulWidget {
  final String quizId;
  final String userId;

  const QuizDetailScreen({
    super.key,
    required this.quizId,
    required this.userId,
  });

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  Map<int, int> selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<QuizProvider>(context, listen: false);
    provider.fetchQuizById(widget.quizId);
  }

  void _submitQuiz(Quiz quiz) async {
    final provider = Provider.of<QuizProvider>(context, listen: false);

    final answers = selectedAnswers.entries
        .map((e) => {
              'questionIndex': e.key,
              'answerIndex': e.value,
            })
        .toList();

    if (answers.length != quiz.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần trả lời tất cả các câu hỏi')),
      );
      return;
    }

    await provider.submitQuiz(widget.quizId, widget.userId, answers);

    if (provider.result != null) {
      final result = provider.result!;
      final scoreText = result['scoreText'];
      final results = result['results'];

      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Kết quả'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Điểm: $scoreText', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                ...results.map<Widget>((r) {
                  final index = r['questionIndex'];
                  final correct = r['correct'] == true;
                  final selectedAnswerIndex = r['selectedAnswerIndex'];
                  final correctAnswerIndex = r['correctAnswerIndex'];

                  final question = quiz.questions[index];
                  final selectedAnswerText = selectedAnswerIndex != null &&
                          selectedAnswerIndex < question.answers.length
                      ? question.answers[selectedAnswerIndex].text
                      : 'Không chọn';
                  final correctAnswerText =
                      question.answers[correctAnswerIndex].text;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: correct ? Colors.green : Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Câu ${index + 1}: ${question.text}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Bạn chọn: $selectedAnswerText',
                            style: TextStyle(
                                color: correct ? Colors.green : Colors.red)),
                        Text('Đáp án đúng: $correctAnswerText',
                            style: const TextStyle(color: Colors.blue)),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); 
              },
              child: const Text('Đóng'),
            ),
          ],
        ),
      ).then((_) {
        Navigator.of(context).pop();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Lỗi không xác định')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final quiz = provider.selectedQuiz;
        if (quiz == null) {
          return const Scaffold(
            body: Center(child: Text("Không tìm thấy bài trắc nghiệm")),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(quiz.title)),
          body: ListView.builder(
            itemCount: quiz.questions.length,
            itemBuilder: (context, index) {
              final question = quiz.questions[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Câu ${index + 1}: ${question.text}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...List.generate(question.answers.length, (i) {
                        final answer = question.answers[i];
                        return RadioListTile<int>(
                          value: i,
                          groupValue: selectedAnswers[index],
                          title: Text(answer.text),
                          onChanged: (val) {
                            setState(() {
                              selectedAnswers[index] = val!;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: provider.isSubmitting
                ? null
                : () {
                    _submitQuiz(quiz);
                  },
            icon: const Icon(Icons.send),
            label: provider.isSubmitting
                ? const Text('Đang gửi...')
                : const Text('Nộp bài'),
          ),
        );
      },
    );
  }
}
