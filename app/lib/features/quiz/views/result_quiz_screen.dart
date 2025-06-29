import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import 'package:intl/intl.dart';
import 'quiz_detail_screen.dart';
import '../../../core/widgets/custom_appbar.dart';

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
    final ButtonStyle beautifulButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF0072ff),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      elevation: 4,
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // nền xám nhẹ
      appBar: CustomAppBar(title: 'Kết quả làm bài'),
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
                                  style: TextStyle(fontSize: 20),
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
                                    color: Colors.white,
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.assignment_turned_in,
                                        color: Colors.green,
                                      ),
                                      title: Text.rich(
                                        TextSpan(
                                          children: [
                                            WidgetSpan(
                                              child: Icon(Icons.emoji_events,
                                                  color: Colors.orange,
                                                  size: 18),
                                              alignment:
                                                  PlaceholderAlignment.middle,
                                            ),
                                            const WidgetSpan(
                                                child: SizedBox(width: 6)),
                                            TextSpan(
                                              text:
                                                  "Điểm: ${result.score ?? 'N/A'}",
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                      subtitle: Text.rich(
                                        TextSpan(
                                          children: [
                                            WidgetSpan(
                                              child: Icon(Icons.access_time,
                                                  size: 16, color: Colors.grey),
                                              alignment:
                                                  PlaceholderAlignment.middle,
                                            ),
                                            const WidgetSpan(
                                                child: SizedBox(width: 6)),
                                            TextSpan(
                                              text:
                                                  "Làm bài lúc: ${formatDateTime(result.testAt)}",
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),

              // Nút "Làm bài"
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                          .copyWith(bottom: 30),
                  child: Center(
                    child: SizedBox(
                      width: 180,
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
                        icon: const Icon(Icons.play_arrow,
                            size: 20, color: Colors.white),
                        label: const Text(
                          "Làm bài",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: beautifulButtonStyle,
                      ),
                    ),
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
