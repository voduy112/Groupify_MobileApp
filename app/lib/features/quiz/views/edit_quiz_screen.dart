import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import '../../../core/widgets/custom_appbar.dart';

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
  final _formKey = GlobalKey<FormState>();

  List<EditableQuestion> _questions = [];
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
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${provider.error}')),
      );
    }
  }

  Future<void> _saveQuestions() async {
    _formKey.currentState?.save();

    final provider = Provider.of<QuizProvider>(context, listen: false);
    List<Map<String, dynamic>> updates = [];

    for (int i = 0; i < _questions.length; i++) {
      EditableQuestion question = _questions[i];

      if (question.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Câu hỏi ${i + 1} không được để trống.')),
        );
        return;
      }

      if (question.answers.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Câu hỏi ${i + 1} phải có ít nhất 2 đáp án.')),
        );
        return;
      }

      for (int j = 0; j < question.answers.length; j++) {
        if (question.answers[j].text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Đáp án ${j + 1} trong câu hỏi ${i + 1} không được để trống.')),
          );
          return;
        }
      }

      bool hasCorrect = question.answers.any((a) => a.isCorrect);
      if (!hasCorrect) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Câu hỏi ${i + 1} phải có ít nhất một đáp án đúng.')),
        );
        return;
      }

      List<Map<String, dynamic>> answers = [];
      for (int j = 0; j < question.answers.length; j++) {
        EditableAnswer a = question.answers[j];
        answers.add({
          'answerIndex': j,
          'text': a.text,
          'isCorrect': a.isCorrect,
        });
      }

      if (i < _originalQuestionCount) {
        updates.add({
          'action': 'update',
          'questionIndex': i,
          'newData': {
            'text': question.text,
            'answers': answers,
          },
        });
      } else {
        updates.add({
          'action': 'add',
          'newData': {
            'text': question.text,
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
      _questions.add(
        EditableQuestion(
          text: '',
          answers: [
            EditableAnswer(text: '', isCorrect: false),
            EditableAnswer(text: '', isCorrect: false),
          ],
        ),
      );
    });
  }

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _addAnswer(int questionIndex) {
    setState(() {
      _questions[questionIndex]
          .answers
          .add(EditableAnswer(text: '', isCorrect: false));
    });
  }

  void _deleteAnswer(int questionIndex, int answerIndex) {
    setState(() {
      _questions[questionIndex].answers.removeAt(answerIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuizProvider>(context);

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
      appBar: CustomAppBar(title: 'Chỉnh sửa Quiz'),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFormField(
                      label: 'Tiêu đề',
                      initialValue: _titleController.text,
                      onSaved: (value) => _titleController.text = value ?? '',
                    ),
                    SizedBox(height: 12),
                    CustomTextFormField(
                      label: 'Mô tả',
                      initialValue: _descriptionController.text,
                      maxLines: 2,
                      onSaved: (value) =>
                          _descriptionController.text = value ?? '',
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      style: beautifulButtonStyle,
                      onPressed: provider.isUpdatingQuiz ? null : _saveQuizInfo,
                      child: provider.isUpdatingQuiz
                          ? CircularProgressIndicator()
                          : Text('Lưu thông tin Quiz'),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      style: beautifulButtonStyle,
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
                      Text('Câu hỏi:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      ..._questions.asMap().entries.map((entry) {
                        int qIndex = entry.key;
                        EditableQuestion question = entry.value;

                        return Card(
                          color: Colors.white,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            // side: BorderSide(color: Colors.blue, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteQuestion(qIndex),
                                    ),
                                  ],
                                ),
                                CustomTextFormField(
                                  label: 'Nội dung câu hỏi',
                                  initialValue: question.text,
                                  onSaved: (value) => _questions[qIndex].text =
                                      value?.trim() ?? '',
                                ),
                                SizedBox(height: 8),
                                ...question.answers.asMap().entries.map((ans) {
                                  int aIndex = ans.key;
                                  EditableAnswer answer = ans.value;
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: CustomTextFormField(
                                            label: 'Đáp án ${aIndex + 1}',
                                            initialValue: answer.text,
                                            onSaved: (value) =>
                                                _questions[qIndex]
                                                    .answers[aIndex]
                                                    .text = value?.trim() ?? '',
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Column(
                                          children: [
                                            Radio<bool>(
                                              value: true,
                                              groupValue: answer.isCorrect,
                                              onChanged: (value) {
                                                setState(() {
                                                  for (var ans
                                                      in question.answers) {
                                                    ans.isCorrect = false;
                                                  }
                                                  answer.isCorrect =
                                                      value ?? false;
                                                });
                                              },
                                            ),
                                            Text('Đúng'),
                                          ],
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _deleteAnswer(qIndex, aIndex),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  style: beautifulButtonStyle,
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
                              style: beautifulButtonStyle,
                              onPressed: _addQuestion,
                              child: Text('Thêm câu hỏi'),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: beautifulButtonStyle,
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
                    ]
                  ],
                ),
              ),
            ),
    );
  }
}
