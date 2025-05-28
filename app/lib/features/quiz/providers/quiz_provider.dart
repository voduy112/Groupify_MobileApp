import 'package:flutter/material.dart';
import '../services/quiz_service.dart';
import '../../../models/quiz.dart';
import '../../../models/resultquiz.dart';

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

  Map<String, dynamic>? _result;
  bool _isSubmitting = false;
  

  Map<String, dynamic>? get result => _result;
  bool get isSubmitting => _isSubmitting;

  List<ResultQuiz> _userResults = [];
  bool _isFetchingResults = false;

  List<ResultQuiz> get userResults => _userResults;
  bool get isFetchingResults => _isFetchingResults;


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

   Future<void> submitQuiz(String quizId, String userId, List<Map<String, dynamic>> answers) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      _result = await _quizService.submitQuizAnswers(
        quizId: quizId,
        userId: userId,
        answers: answers,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSubmitting = false;
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

  Future<void> fetchResultsByQuizIdAndUserId({
    required String quizId,
    required String userId,
  }) async {
    _isFetchingResults = true;
    _error = null;
    notifyListeners();

    try {
      _userResults = await _quizService.getResultsByQuizIdAndUserId(
        quizId: quizId,
        userId: userId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isFetchingResults = false;
      notifyListeners();
    }
  }

  void clearResults() {
    _userResults = [];
    notifyListeners();
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
