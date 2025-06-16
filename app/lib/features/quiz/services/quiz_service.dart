import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../models/quiz.dart';
import '../../../services/api/dio_client.dart';

class QuizService {
  final Dio _dio;

  QuizService() : _dio = DioClient.instance;

  Future<List<Quiz>> getAllQuizzesByGroupId(String groupId) async {
    try {
      final response = await _dio.get('/api/quiz/group/$groupId');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Quiz.fromJson(json)).toList();
      } else {
        throw Exception("Lỗi khi lấy danh sách bộ câu hỏi theo nhóm ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi getAllQuizzesByGroupId: $e");
      rethrow;
    }
  }
  Future<Quiz> getquiz(String quizId) async {
    try {
      final response = await _dio.get('/api/quiz/$quizId');
      if (response.statusCode == 200) {
        return Quiz.fromJson(response.data);
      } else {
        throw Exception("Lỗi khi lấy câu hỏi: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi getQuiz: $e");
      rethrow;
    }
  }
}