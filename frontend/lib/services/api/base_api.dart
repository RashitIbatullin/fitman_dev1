import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// A base class for API services that handles common logic like
/// base URL, authentication token, and HTTP headers.
class BaseApiService {
  /// The base URL for all API requests.
  /// It's retrieved from the .env file.
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:8080';

  /// The static authentication token.
  static String? _token;

  /// Getter for the current authentication token.
  static String? get currentToken => _token;

  /// Initializes the service by loading the token from shared preferences.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  /// Saves the authentication token to memory and shared preferences.
  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Clears the authentication token from memory and shared preferences.
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Returns the default headers for API requests, including the auth token if available.
  static Map<String, String> get headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (currentToken != null) {
      headers['Authorization'] = 'Bearer $currentToken';
      print('DEBUG: Authorization header added with token: $currentToken');
    } else {
      print('DEBUG: No Authorization header added. Current token is null.');
    }
    return headers;
  }

  /// A reusable HTTP client.
  final http.Client client;

  BaseApiService({http.Client? client}) : client = client ?? http.Client();

  /// Helper method to perform a GET request.
  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
    final response = await client.get(uri, headers: BaseApiService.headers);
    return _handleResponse(response);
  }

  /// Helper method to perform a POST request.
  Future<dynamic> post(String endpoint, {required Map<String, dynamic> body}) async {
    final response = await client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: BaseApiService.headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// Helper method to perform a PUT request.
  Future<dynamic> put(String endpoint, {required Map<String, dynamic> body}) async {
    final response = await client.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: BaseApiService.headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// Helper method to perform a DELETE request.
  Future<void> delete(String endpoint, {Map<String, dynamic>? body}) async { // MODIFIED to accept body
    final response = await client.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: BaseApiService.headers,
      body: body != null ? jsonEncode(body) : null, // ADDED body encoding
    );
    if (response.statusCode > 204) { // Changed from != 204 to > 204 for more robust check
      _handleResponse(response);
    }
  }
  
    /// Helper method for multipart POST requests (file uploads).
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
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseBody.isEmpty) return null;
      return jsonDecode(responseBody);
    } else {
      final errorData = jsonDecode(responseBody);
      throw Exception(
        errorData['error'] ?? 'Request failed with status ${response.statusCode}',
      );
    }
  }


  /// Handles the HTTP response, decoding JSON and throwing an exception on error.
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
        errorData['error'] ?? 'Request failed with status ${response.statusCode}',
      );
    }
  }
}