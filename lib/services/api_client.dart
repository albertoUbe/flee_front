import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  static final http.Client _client = http.Client();

  static Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static dynamic _parse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    final body = response.body;
    throw ApiException(response.statusCode, body.isNotEmpty ? body : 'Error ${response.statusCode}');
  }

  static Future<dynamic> get(String url) async {
    final response = await _client.get(Uri.parse(url), headers: _jsonHeaders);
    return _parse(response);
  }

  static Future<dynamic> post(String url, Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse(url),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );
    return _parse(response);
  }

  static Future<dynamic> put(String url, Map<String, dynamic> body) async {
    final response = await _client.put(
      Uri.parse(url),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );
    return _parse(response);
  }

  static Future<void> delete(String url) async {
    final response = await _client.delete(Uri.parse(url), headers: _jsonHeaders);
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
  }

  static Future<dynamic> postMultipart(
    String url,
    Map<String, String> fields, {
    Uint8List? fileBytes,
    String? fileName,
    String? fileField,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields.addAll(fields);

    if (fileBytes != null && fileField != null && fileName != null) {
      final extension = fileName.split('.').last.toLowerCase();
      final contentType = extension == 'png'
          ? MediaType('image', 'png')
          : MediaType('image', 'jpeg');
      final file = http.MultipartFile.fromBytes(
        fileField,
        fileBytes,
        filename: fileName,
        contentType: contentType,
      );
      request.files.add(file);
    }

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    return _parse(response);
  }

  static Future<dynamic> putMultipart(
    String url,
    Map<String, String> fields, {
    Uint8List? fileBytes,
    String? fileName,
    String? fileField,
  }) async {
    final request = http.MultipartRequest('PUT', Uri.parse(url));
    request.fields.addAll(fields);

    if (fileBytes != null && fileField != null && fileName != null) {
      final extension = fileName.split('.').last.toLowerCase();
      final contentType = extension == 'png'
          ? MediaType('image', 'png')
          : MediaType('image', 'jpeg');
      final file = http.MultipartFile.fromBytes(
        fileField,
        fileBytes,
        filename: fileName,
        contentType: contentType,
      );
      request.files.add(file);
    }

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    return _parse(response);
  }
}
