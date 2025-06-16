import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import 'package:intl/intl.dart';
import 'quiz_detail_screen.dart';

class ResultQuizScreen extends StatefulWidget {
  final String quizId;
  final String userId;

  const ResultQuizScreen({
    Key? key,
    required this.quizId,
    required this.userId,
  }) : super(key: key);

  @override
  State<ResultQuizScreen> createState() => _ResultQuizScreenState();
}

class _ResultQuizScreenState extends State<ResultQuizScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      quizProvider.fetchResultsByQuizIdAndUserId(
        quizId: widget.quizId,
        userId: widget.userId,
      );
    });
  }

  String formatDateTime(String? dateStr) {
    if (dateStr == null) return "Không rõ";
    final dateTime = DateTime.tryParse(dateStr);
    if (dateTime == null) return "Không rõ";
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả làm bài')),
      body: Consumer<QuizProvider>(
        builder: (context, provider, _) {
          final results = provider.userResults;

          return Column(
            children: [
              Expanded(
                child: provider.isFetchingResults
                    ? const Center(child: CircularProgressIndicator())
                    : provider.error != null
                        ? Center(child: Text("Lỗi: ${provider.error}"))
                        : results.isEmpty
                            ? const Center(
                                child: Text(
                                  "Bạn chưa làm bộ câu hỏi này",
                                  style: TextStyle(fontSize: 30),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: results.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final result = results[index];
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.assignment_turned_in,
                                        color: Colors.green,
                                      ),
                                      title: Text(
                                          "Điểm: ${result.score ?? 'N/A'}"),
                                      subtitle: Text(
                                        "Làm bài lúc: ${formatDateTime(result.testAt)}",
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),

              // Nút bên dưới
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                          .copyWith(bottom: 30),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuizDetailScreen(
                                  quizId: widget.quizId,
                                  userId: widget.userId,
                                ),
                              ),
                            ).then((_) {
                              final quizProvider = Provider.of<QuizProvider>(
                                  context,
                                  listen: false);
                              quizProvider.fetchResultsByQuizIdAndUserId(
                                quizId: widget.quizId,
                                userId: widget.userId,
                              );
                            });
                          },
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text("Làm bài"),
                          style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                            backgroundColor:
                                const Color.fromARGB(255, 39, 161, 213),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text("Trở về"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
