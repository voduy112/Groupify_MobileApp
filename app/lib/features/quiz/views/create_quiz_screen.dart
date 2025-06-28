import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validate.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import '../providers/quiz_provider.dart';
import '../../../core/widgets/custom_appbar.dart';

class CreateQuizScreen extends StatefulWidget {
  final String groupId;

  const CreateQuizScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _title, _description;

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
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất 1 câu hỏi.')),
      );
      return;
    }

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final questionText = Validate.normalizeText(question['text'] ?? '');

      if (questionText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Câu hỏi ${i + 1} không được để trống.')),
        );
        return;
      }

      final validAnswers = (question['answers'] as List)
          .where((a) => Validate.normalizeText(a['text'] ?? '').isNotEmpty)
          .toList();

      if (validAnswers.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Câu hỏi ${i + 1} cần ít nhất 2 đáp án hợp lệ.')),
        );
        return;
      }

      final hasCorrect = validAnswers.any((a) => a['isCorrect'] == true);
      if (!hasCorrect) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Câu hỏi ${i + 1} cần chọn một đáp án đúng.')),
        );
        return;
      }

      question['answers'] = validAnswers;
    }

    final provider = Provider.of<QuizProvider>(context, listen: false);

    await provider.createQuiz(
      title: _title!,
      description: _description!,
      groupId: widget.groupId,
      questions: _questions,
    );

    if (provider.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo quiz thành công!')),
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
      appBar: CustomAppBar(
        title: 'Tạo bộ câu hỏi mới',
        actions: [
          IconButton(
            icon: const Icon(
              Icons.check,
              color: Colors.white,
              size: 30,
            ),
            onPressed: provider.isCreating ? null : _submitQuiz,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFormField(
                label: 'Tiêu đề',
                fieldName: 'Tiêu đề',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
                onSaved: (val) => _title = val,
              ),
              const SizedBox(height: 12),
              CustomTextFormField(
                label: 'Mô tả',
                fieldName: 'Mô tả',
                maxLines: 2,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập mô tả';
                  }
                  return null;
                },
                onSaved: (val) => _description = val,
              ),
              const SizedBox(height: 16),
              const Text(
                'Câu hỏi:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._questions.asMap().entries.map((entry) {
                int qIndex = entry.key;
                Map<String, dynamic> question = entry.value;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextFormField(
                          label: 'Câu hỏi ${qIndex + 1}',
                          fieldName: 'Câu hỏi ${qIndex + 1}',
                          initialValue: question['text'],
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Vui lòng nhập nội dung câu hỏi';
                            }
                            return null;
                          },
                          onSaved: (val) => question['text'] = val ?? '',
                        ),
                        const SizedBox(height: 8),
                        ...question['answers'].asMap().entries.map((ansEntry) {
                          int aIndex = ansEntry.key;
                          Map<String, dynamic> answer = ansEntry.value;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: CustomTextFormField(
                                    label: 'Đáp án ${aIndex + 1}',
                                    fieldName: 'Đáp án ${aIndex + 1}',
                                    initialValue: answer['text'],
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Vui lòng nhập đáp án';
                                      }
                                      return null;
                                    },
                                    onSaved: (val) =>
                                        answer['text'] = val ?? '',
                                  ),
                                ),
                                Radio<bool>(
                                  value: true,
                                  groupValue: answer['isCorrect'] == true,
                                  onChanged: (value) {
                                    setState(() {
                                      for (var ans in question['answers']) {
                                        ans['isCorrect'] = false;
                                      }
                                      answer['isCorrect'] = true;
                                    });
                                  },
                                ),
                                const Text('Đúng'),
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
                          child: const Text('Thêm đáp án'),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  style: beautifulButtonStyle,
                  onPressed: _addQuestion,
                  child: const Text(
                    'Thêm câu hỏi',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
