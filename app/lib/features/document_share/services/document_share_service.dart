import 'package:dio/dio.dart';
import '../../../models/document.dart';
import '../../../services/api/dio_client.dart';

class DocumentShareService {
  final Dio _dio;

  DocumentShareService() : _dio = DioClient.instance;

  Future<List<Document>> getDocuments() async {
    final response = await _dio.get('/api/document');
    print("response.data: ${response.data}");
    return (response.data as List)
        .map((json) => Document.fromJson(json))
        .toList();
  }
}
