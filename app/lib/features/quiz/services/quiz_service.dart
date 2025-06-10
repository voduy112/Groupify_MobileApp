import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../models/quiz.dart';
import '../../../models/resultquiz.dart';
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
        throw Exception(
            "Lỗi khi lấy danh sách bộ câu hỏi theo nhóm ${response.statusCode}");
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

  Future<Map<String, dynamic>> submitQuizAnswers({
    required String quizId,
    required String userId,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final dataToSend = {
        'userId': userId,
        'answers': answers,
      };

      print("Dữ liệu gửi lên: $dataToSend");

      final response =
          await _dio.post('/api/quiz/$quizId/check', data: dataToSend);
      print("Phản hồi từ server: ${response.data}");
      return response.data;
    } catch (e) {
      print("Lỗi submitQuizAnswers: $e");
      throw Exception('Lỗi khi gửi kết quả làm bài: $e');
    }
  }

  Future<List<ResultQuiz>> getResultsByQuizIdAndUserId({
  required String quizId,
  required String userId,
}) async {
  try {
    final response = await _dio.get('/api/result/quiz/$quizId/user/$userId');

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((json) => ResultQuiz.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      // Không có kết quả -> trả về danh sách rỗng
      return [];
    } else {
      throw Exception(
        "Lỗi khi lấy kết quả làm bài: ${response.statusCode}",
      );
    }
  } on DioException catch (e) {
    // Trường hợp backend trả 404 như là lỗi (với `validateStatus`)
    if (e.response?.statusCode == 404) {
      return []; // coi như không có kết quả
    } else {
      print("Lỗi Dio: ${e.message}");
      rethrow;
    }
  } catch (e) {
    print("Lỗi không xác định: $e");
    rethrow;
  }
}
  // trong QuizService

  Future<Quiz> createQuiz({
    required String title,
    required String description,
    required String groupId,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      final dataToSend = {
        'title': title,
        'description': description,
        'groupId': groupId,
        'questions': questions,
      };

      final response = await _dio.post('/api/quiz/', data: dataToSend);

      if (response.statusCode == 201) {
        return Quiz.fromJson(response.data['quiz']);
      } else {
        throw Exception('Lỗi khi tạo quiz: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi createQuiz: $e');
      rethrow;
    }
  }

  Future<void> updateQuiz({
    required String quizId,
    String? title,
    String? description,
    String? groupId,
  }) async {
    try {
      final dataToSend = {
        'title': title,
        'description': description,
        'groupId': groupId,
      };

      final response = await _dio.patch('/api/quiz/$quizId', data: dataToSend);

      if (response.statusCode != 200) {
        throw Exception('Lỗi khi cập nhật quiz: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi updateQuiz: $e');
      rethrow;
    }
  }

  Future<void> updateQuestions({
    required String quizId,
    required List<Map<String, dynamic>> updates,
  }) async {
    try {
      final response = await _dio.patch(
        '/api/quiz/$quizId/question',
        data: {'updates': updates},
      );

      if (response.statusCode != 200) {
        throw Exception('Lỗi khi cập nhật câu hỏi: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi updateQuestions: $e');
      rethrow;
    }
  }
}
