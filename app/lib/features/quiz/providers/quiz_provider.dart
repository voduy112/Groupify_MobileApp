import 'package:flutter/material.dart';
import '../services/quiz_service.dart';
import '../../../models/quiz.dart';

class QuizProvider extends ChangeNotifier {
  final QuizService _quizService = QuizService();

  List<Quiz> _quizzes = [];
  Quiz? _selectedQuiz;
  bool _isLoading = false;
  String? _error;

  List<Quiz> get quizzes => _quizzes;
  Quiz? get selectedQuiz => _selectedQuiz;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchQuizzesByGroupId(String groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _quizzes = await _quizService.getAllQuizzesByGroupId(groupId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchQuizById(String quizId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedQuiz = await _quizService.getquiz(quizId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedQuiz() {
    _selectedQuiz = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
