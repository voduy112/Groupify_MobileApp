import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpClient {
  static const String baseUrl = 'http://10.0.2.2:5000';
  static final http.Client _client = http.Client();

  /// GET request
  static Future<http.Response> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    return await _client.get(uri, headers: _defaultHeaders());
  }

  /// POST request
  static Future<http.Response> post(
      String path, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$path');
    return await _client.post(
      uri,
      headers: _defaultHeaders(),
      body: jsonEncode(data),
    );
  }

  /// PUT request
  static Future<http.Response> put(
      String path, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$path');
    return await _client.put(
      uri,
      headers: _defaultHeaders(),
      body: jsonEncode(data),
    );
  }

  /// PATCH request
  static Future<http.Response> patch(
      String path, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$path');
    return await _client.patch(
      uri,
      headers: _defaultHeaders(),
      body: jsonEncode(data),
    );
  }

  /// DELETE request (optional body)
  static Future<http.Response> delete(String path,
      [Map<String, dynamic>? data]) async {
    final uri = Uri.parse('$baseUrl$path');
    return await _client.delete(
      uri,
      headers: _defaultHeaders(),
      body: data != null ? jsonEncode(data) : null,
    );
  }

  /// Default headers for all requests
  static Map<String, String> _defaultHeaders() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
