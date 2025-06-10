import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';

// MODEL
class EditableAnswer {
  String text;
  bool isCorrect;

  EditableAnswer({required this.text, required this.isCorrect});
}

class EditableQuestion {
  String text;
  List<EditableAnswer> answers;

  EditableQuestion({required this.text, required this.answers});
}

class EditQuizScreen extends StatefulWidget {
  final String quizId;

  const EditQuizScreen({Key? key, required this.quizId}) : super(key: key);

  @override
  State<EditQuizScreen> createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<EditableQuestion> _questions = [];
  List<TextEditingController> _questionControllers = [];
  List<List<TextEditingController>> _answerControllers = [];

  bool _showQuestions = false;
  bool _isQuizLoaded = false;
  int _originalQuestionCount = 0;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    final provider = Provider.of<QuizProvider>(context, listen: false);
    await provider.fetchQuizById(widget.quizId);

    final quiz = provider.selectedQuiz;

    if (quiz != null) {
      _titleController.text = quiz.title;
      _descriptionController.text = quiz.description;
      _originalQuestionCount = quiz.questions.length;

      _questions = quiz.questions
          .map((q) => EditableQuestion(
                text: q.text,
                answers: q.answers
                    .map((a) =>
                        EditableAnswer(text: a.text, isCorrect: a.isCorrect))
                    .toList(),
              ))
          .toList();

      _questionControllers =
          _questions.map((q) => TextEditingController(text: q.text)).toList();

      _answerControllers = _questions
          .map((q) => q.answers
              .map((a) => TextEditingController(text: a.text))
              .toList())
          .toList();

      _isQuizLoaded = true;
      setState(() {});
    }
  }

  Future<void> _saveQuizInfo() async {
    final provider = Provider.of<QuizProvider>(context, listen: false);
    await provider.updateQuiz(
      quizId: widget.quizId,
      title: _titleController.text,
      description: _descriptionController.text,
    );

    if (provider.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thông tin quiz thành công!')),
      );

      // Chuyển về trang trước sau khi lưu thành công
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${provider.error}')),
      );
    }
  }

  Future<void> _saveQuestions() async {
    final provider = Provider.of<QuizProvider>(context, listen: false);

    List<Map<String, dynamic>> updates = [];

    for (int i = 0; i < _questions.length; i++) {
      EditableQuestion q = _questions[i];

      List<Map<String, dynamic>> answers = [];
      for (int j = 0; j < q.answers.length; j++) {
        EditableAnswer a = q.answers[j];
        answers.add({
          'answerIndex': j,
          'text': a.text,
          'isCorrect': a.isCorrect,
        });
      }

      if (i < _originalQuestionCount) {
        // Câu hỏi cũ → update
        updates.add({
          'action': 'update',
          'questionIndex': i,
          'newData': {
            'text': q.text,
            'answers': answers,
          },
        });
      } else {
        // Câu hỏi mới → add
        updates.add({
          'action': 'add',
          'newData': {
            'text': q.text,
            'answers': answers,
          },
        });
      }
    }

    await provider.updateQuestions(
      quizId: widget.quizId,
      updates: updates,
    );

    if (provider.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật câu hỏi thành công!')),
      );
      _originalQuestionCount = _questions.length;
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          _showQuestions = false;
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${provider.error}')),
      );
    }
  }

  void _addQuestion() {
    if (!_isQuizLoaded) return;

    setState(() {
      EditableQuestion newQuestion = EditableQuestion(
        text: '',
        answers: [
          EditableAnswer(text: '', isCorrect: false),
          EditableAnswer(text: '', isCorrect: false),
        ],
      );

      _questions.add(newQuestion);
      _questionControllers.add(TextEditingController());
      _answerControllers.add([
        TextEditingController(),
        TextEditingController(),
      ]);
    });
  }

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      _questionControllers.removeAt(index);
      _answerControllers.removeAt(index);
    });
  }

  void _addAnswer(int questionIndex) {
    setState(() {
      _questions[questionIndex]
          .answers
          .add(EditableAnswer(text: '', isCorrect: false));
      _answerControllers[questionIndex].add(TextEditingController());
    });
  }

  void _deleteAnswer(int questionIndex, int answerIndex) {
    setState(() {
      _questions[questionIndex].answers.removeAt(answerIndex);
      _answerControllers[questionIndex].removeAt(answerIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuizProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Chỉnh sửa Quiz')),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    maxLines: 2,
                    decoration: InputDecoration(labelText: 'Mô tả'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800], // Xanh dương đậm
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: provider.isUpdatingQuiz ? null : _saveQuizInfo,
                    child: provider.isUpdatingQuiz
                        ? CircularProgressIndicator()
                        : Text('Lưu thông tin Quiz'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800], // Xanh dương đậm
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: () {
                      setState(() {
                        _showQuestions = !_showQuestions;
                      });
                    },
                    child: Text(_showQuestions
                        ? 'Ẩn chỉnh sửa câu hỏi'
                        : 'Chỉnh sửa câu hỏi'),
                  ),
                  SizedBox(height: 16),
                  if (_showQuestions) ...[
                    Text(
                      'Câu hỏi:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    ..._questions.asMap().entries.map((entry) {
                      int qIndex = entry.key;
                      EditableQuestion question = entry.value;

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: Colors.blue, width: 2), // viền xanh dương
                          borderRadius: BorderRadius.circular(8), // bo góc đẹp
                        ),
                        color: Colors.white, // nền trắng
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Câu hỏi ${qIndex + 1}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteQuestion(qIndex),
                                  ),
                                ],
                              ),
                              TextField(
                                decoration: InputDecoration(
                                    labelText: 'Nội dung câu hỏi'),
                                controller: _questionControllers[qIndex],
                                onChanged: (value) {
                                  question.text = value;
                                },
                              ),
                              SizedBox(height: 8),
                              ...question.answers
                                  .asMap()
                                  .entries
                                  .map((ansEntry) {
                                int aIndex = ansEntry.key;
                                EditableAnswer answer = ansEntry.value;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            decoration: InputDecoration(
                                              labelText: 'Đáp án ${aIndex + 1}',
                                            ),
                                            controller:
                                                _answerControllers[qIndex]
                                                    [aIndex],
                                            onChanged: (value) {
                                              answer.text = value;
                                            },
                                          ),
                                        ),
                                        Checkbox(
                                          value: answer.isCorrect,
                                          onChanged: (value) {
                                            setState(() {
                                              // Chỉ cho phép 1 đáp án đúng
                                              question.answers.forEach((ans) {
                                                ans.isCorrect = false;
                                              });
                                              answer.isCorrect = value!;
                                            });
                                          },
                                        ),
                                        Text('Đúng'),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _deleteAnswer(qIndex, aIndex),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                );
                              }).toList(),
                              SizedBox(height: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.blue[800], // Xanh dương đậm
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                ),
                                onPressed: () => _addAnswer(qIndex),
                                child: Text('Thêm đáp án'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.blue[800], // Xanh dương đậm
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                            onPressed: _addQuestion,
                            child: Text('Thêm câu hỏi'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.blue[800], // Xanh dương đậm
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                            onPressed: provider.isUpdatingQuestions
                                ? null
                                : _saveQuestions,
                            child: provider.isUpdatingQuestions
                                ? CircularProgressIndicator()
                                : Text('Lưu câu hỏi'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ],
              ),
            ),
    );
  }
}
