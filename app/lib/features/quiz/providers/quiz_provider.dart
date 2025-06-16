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

  int _count = 0;
  int get count => _count;

  bool _isCreating = false;
  bool get isCreating => _isCreating;

  bool _isDeletingQuiz = false;
  bool get isDeletingQuiz => _isDeletingQuiz;


  Future<void> createQuiz({
    required String title,
    required String description,
    required String groupId,
    required List<Map<String, dynamic>> questions,
  }) async {
    _isCreating = true;
    _error = null;
    notifyListeners();

    try {
      Quiz newQuiz = await _quizService.createQuiz(
        title: title,
        description: description,
        groupId: groupId,
        questions: questions,
      );

      _quizzes.add(newQuiz);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

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

  Future<void> fetchCountByGroupId(String groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      List<Quiz> quizzes = await _quizService.getAllQuizzesByGroupId(groupId);
      _count = quizzes.length;
    } catch (e) {
      _error = 'Lỗi khi lấy số lượng bộ câu hỏi: $e';
      _count = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitQuiz(
      String quizId, String userId, List<Map<String, dynamic>> answers) async {
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

  bool _isUpdatingQuiz = false;
  bool get isUpdatingQuiz => _isUpdatingQuiz;

  bool _isUpdatingQuestions = false;
  bool get isUpdatingQuestions => _isUpdatingQuestions;

  Future<void> updateQuiz({
    required String quizId,
    String? title,
    String? description,
    String? groupId,
  }) async {
    _isUpdatingQuiz = true;
    _error = null;
    notifyListeners();

    try {
      await _quizService.updateQuiz(
        quizId: quizId,
        title: title,
        description: description,
        groupId: groupId,
      );

      await fetchQuizById(quizId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isUpdatingQuiz = false;
      notifyListeners();
    }
  }

  Future<void> updateQuestions({
    required String quizId,
    required List<Map<String, dynamic>> updates,
  }) async {
    _isUpdatingQuestions = true;
    _error = null;
    notifyListeners();

    try {
      await _quizService.updateQuestions(
        quizId: quizId,
        updates: updates,
      );

      await fetchQuizById(quizId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isUpdatingQuestions = false;
      notifyListeners();
    }
  }

  bool _isDeletingGroupQuizzes = false;
  bool get isDeletingGroupQuizzes => _isDeletingGroupQuizzes;

  Future<void> deleteQuizzesByGroupId(String groupId) async {
    _isDeletingGroupQuizzes = true;
    _error = null;
    notifyListeners();

    try {
      int deleted = await _quizService.deleteQuizzesByGroupId(groupId);
      _quizzes.removeWhere((quiz) => quiz.groupId == groupId);
      print("Đã xoá $deleted quizzes của groupId: $groupId");
    } catch (e) {
      _error = e.toString();
    } finally {
      _isDeletingGroupQuizzes = false;
      notifyListeners();
    }
  }
  Future<void> deleteQuizById(String quizId) async {
    _isDeletingQuiz = true;
    _error = null;
    notifyListeners();

    try {
      await _quizService.deleteQuizById(quizId);
      _quizzes.removeWhere((quiz) => quiz.id == quizId);
      if (_selectedQuiz?.id == quizId) {
        _selectedQuiz = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isDeletingQuiz = false;
      notifyListeners();
    }
  }


}
