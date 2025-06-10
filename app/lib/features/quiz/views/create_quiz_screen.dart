import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';

class CreateQuizScreen extends StatefulWidget {
  final String groupId;

  const CreateQuizScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Map<String, dynamic>> _questions = [];

  void _addQuestion() {
    setState(() {
      _questions.add({
        'text': '',
        'answers': [
          {'text': '', 'isCorrect': false},
          {'text': '', 'isCorrect': false},
        ],
      });
    });
  }

  void _submitQuiz() async {
    final provider = Provider.of<QuizProvider>(context, listen: false);

    await provider.createQuiz(
      title: _titleController.text,
      description: _descriptionController.text,
      groupId: widget.groupId,
      questions: _questions,
    );

    if (provider.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo quiz thành công!')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${provider.error}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuizProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo Quiz Mới'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Tiêu đề'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 2, // nhỏ lại 1 chút
              decoration: InputDecoration(
                labelText: 'Mô tả',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Câu hỏi:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ..._questions.asMap().entries.map((entry) {
              int qIndex = entry.key;
              Map<String, dynamic> question = entry.value;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Câu hỏi ${qIndex + 1}',
                        ),
                        onChanged: (value) => question['text'] = value,
                      ),
                      SizedBox(height: 8),
                      ...question['answers'].asMap().entries.map((ansEntry) {
                        int aIndex = ansEntry.key;
                        Map<String, dynamic> answer = ansEntry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Đáp án ${aIndex + 1}',
                                  ),
                                  onChanged: (value) => answer['text'] = value,
                                ),
                              ),
                              Checkbox(
                                value: answer['isCorrect'],
                                onChanged: (value) {
                                  setState(() {
                                    // Đặt tất cả đáp án trong câu hỏi này về false
                                    question['answers'].forEach((ans) {
                                      ans['isCorrect'] = false;
                                    });

                                    // Chỉ đáp án này là true
                                    answer['isCorrect'] = value!;
                                  });
                                },
                              ),
                              Text('Đúng'),
                            ],
                          ),
                        );
                      }).toList(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            question['answers']
                                .add({'text': '', 'isCorrect': false});
                          });
                        },
                        child: Text('Thêm đáp án'),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: 12),
            // Nút Thêm Câu hỏi ở dưới
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800], // Xanh dương đậm
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: _addQuestion,
                child: Text(
                  'Thêm câu hỏi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Nút Tạo Quiz
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: provider.isCreating ? null : _submitQuiz,
                child: provider.isCreating
                    ? CircularProgressIndicator()
                    : Text(
                        'Tạo Quiz',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
