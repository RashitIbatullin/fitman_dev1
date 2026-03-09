import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BaseApiService {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:8080';

  static String? _token;
  static String? get currentToken => _token;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Map<String, String> get headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (currentToken != null) {
      headers['Authorization'] = 'Bearer $currentToken';
    }
    return headers;
  }

  final http.Client client;

  BaseApiService({http.Client? client}) : client = client ?? http.Client();

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
    final response = await client.get(uri, headers: BaseApiService.headers);
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, {required Map<String, dynamic> body}) async {
    final response = await client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: BaseApiService.headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, {required Map<String, dynamic> body}) async {
    final response = await client.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: BaseApiService.headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<void> delete(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await client.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: BaseApiService.headers,
      body: body != null ? jsonEncode(body) : null,
    );
    if (response.statusCode >= 400) {
      _handleResponse(response);
    }
  }

  Future<dynamic> multipartPost(
    String endpoint, {
    required Map<String, String> fields,
    required http.MultipartFile file,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
    request.headers.addAll(BaseApiService.headers);
    request.fields.addAll(fields);
    request.files.add(file);

    final response = await request.send();
    return _handleStreamedResponse(response);
  }

  dynamic _handleStreamedResponse(http.StreamedResponse response) async {
    final responseBody = await response.stream.bytesToString();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseBody.isEmpty) return null;
      return jsonDecode(responseBody);
    } else {
      String errorMessage = 'Request failed with status ${response.statusCode}';
      try {
        final errorData = jsonDecode(responseBody);
        if (errorData is Map && errorData.containsKey('error')) {
          final errorMsgFromServer = errorData['error'];
          if (errorMsgFromServer != null) {
            errorMessage = errorMsgFromServer.toString();
          }
        }
      } catch (e) {
        if (responseBody.isNotEmpty) {
          errorMessage = responseBody;
        }
      }
      throw Exception(errorMessage);
    }
  }
  
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      String errorMessage = 'Request failed with status ${response.statusCode}';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData is Map && errorData.containsKey('error')) {
          final errorMsgFromServer = errorData['error'];
          if (errorMsgFromServer != null) {
            errorMessage = errorMsgFromServer.toString();
          }
        }
      } catch (e) {
        if (response.body.isNotEmpty) {
          errorMessage = response.body;
        }
      }
      throw Exception(errorMessage);
    }
  }
}
