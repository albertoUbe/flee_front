import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:flee_front/core/common/constants.dart';
import 'package:flee_front/core/exceptions/exceptions.dart';

// Conexión con la API de C#.
class ApiService {
  final String _base = Constants.baseUrl;

  // Cabeceras para peticiones JSON
  final Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ───────────────────────────────────────────────
  // AUTH  (UserController)
  // ───────────────────────────────────────────────

  /// POST /api/user/signin
  /// Body: { "email": "", "password": "" }
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final uri = Uri.parse('$_base/user/signin');
    final body = jsonEncode({'email': email, 'password': password});

    final response = await _post(uri, body);
    // El backend devuelve 201 en caso de éxito con CreatedAtAction
    _guard(
      response,
      expected: [200, 201],
      onUnauthorized: AuthInvalidFailure(),
    );
    return _decode(response);
  }

  /// POST /api/user/signup
  /// Body: { "email", "name", "password", "confirmPassword" }
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final uri = Uri.parse('$_base/user/signup');
    final body = jsonEncode({
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    });

    final response = await _post(uri, body);
    _guard(
      response,
      expected: [200, 201],
      onUnauthorized: UserAlreadyExistsFailure(),
    );
    return _decode(response);
  }

  // ───────────────────────────────────────────────
  // COMMUNITIES  (CommunityController)
  // ───────────────────────────────────────────────

  /// GET /api/community
  Future<List<dynamic>> getAllCommunities() async {
    final uri = Uri.parse('$_base/community');
    final response = await _get(uri);
    _guard(response, expected: [200]);
    return jsonDecode(response.body) as List<dynamic>;
  }

  /// GET /api/community/user/{userId}
  Future<List<dynamic>> getCommunitiesByUser(int userId) async {
    final uri = Uri.parse('$_base/community/user/$userId');
    final response = await _get(uri);
    _guard(response, expected: [200]);
    return jsonDecode(response.body) as List<dynamic>;
  }

  /// POST /api/community
  /// Body: CommunityCreateDto { creatorId, name, description, duration }
  Future<Map<String, dynamic>> createCommunity({
    required int creatorId,
    required String name,
    required String description,
    required int duration,
  }) async {
    final uri = Uri.parse('$_base/community');
    final body = jsonEncode({
      'creatorId': creatorId,
      'name': name,
      'description': description,
      'duration': duration,
    });
    final response = await _post(uri, body);
    _guard(response, expected: [200, 201]);
    return _decode(response);
  }

  /// POST /api/community/{idCommunity}/follow/{userId}
  Future<void> followUnfollow(int userId, int communityId) async {
    final uri = Uri.parse('$_base/community/$communityId/follow/$userId');
    final response = await http.post(uri, headers: _jsonHeaders);
    _guard(response, expected: [200]);
  }

  Future<void> manageAdmin(int userId, int ownerId, int communityId) async {
    final uri = Uri.parse(
      '$_base/community/$communityId/$ownerId/admin/$userId',
    );
    final response = await http.post(uri, headers: _jsonHeaders);
    _guard(response, expected: [200]);
  }

  // ───────────────────────────────────────────────
  // POSTS  (PostController)
  // ───────────────────────────────────────────────
  /// GET /api/post
  Future<List<dynamic>> getAllPosts() async {
    final uri = Uri.parse('$_base/post');
    final response = await _get(uri);
    _guard(response, expected: [200]);
    return jsonDecode(response.body) as List<dynamic>;
  }

  /// GET /api/post/community/{communityId}
  Future<List<dynamic>> getPostsByCommunity(int communityId) async {
    final uri = Uri.parse('$_base/post/community/$communityId');
    final response = await _get(uri);
    _guard(response, expected: [200]);
    return jsonDecode(response.body) as List<dynamic>;
  }

  /// POST /api/post  (multipart/form-data porque admite imagen opcional)
  /// Campos: userId, communityId, text + file (opcional)
  Future<Map<String, dynamic>> createPost({
    required int userId,
    required int communityId,
    required String text,
    File? image,
  }) async {
    final uri = Uri.parse('$_base/post');
    final request = http.MultipartRequest('POST', uri);

    request.fields['userId'] = userId.toString();
    request.fields['communityId'] = communityId.toString();
    request.fields['text'] = text;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    _guard(response, expected: [200, 201]);
    return _decode(response);
  }

  /// POST /api/post/{postId}/vote/{userId}
  Future<void> votePost(int postId, int userId) async {
    final uri = Uri.parse('$_base/post/$postId/vote/$userId');
    final response = await http.post(uri, headers: _jsonHeaders);
    _guard(response, expected: [200]);
  }

  /// DELETE /api/post/{id}
  Future<void> deletePost(int id) async {
    final uri = Uri.parse('$_base/post/$id');
    final response = await http.delete(uri, headers: _jsonHeaders);
    _guard(response, expected: [204]);
  }

  // ───────────────────────────────────────────────
  // Helpers privados
  // ───────────────────────────────────────────────

  Future<http.Response> _get(Uri uri) async {
    try {
      return await http.get(uri, headers: _jsonHeaders);
    } catch (_) {
      throw ServerFailure();
    }
  }

  Future<http.Response> _post(Uri uri, String body) async {
    try {
      return await http.post(uri, headers: _jsonHeaders, body: body);
    } catch (_) {
      throw ServerFailure();
    }
  }

  /// Lanza la excepción adecuada si el status code no es el esperado.
  void _guard(
    http.Response response, {
    required List<int> expected,
    Exceptions? onUnauthorized,
  }) {
    if (expected.contains(response.statusCode)) return;
    if (response.statusCode == 401 && onUnauthorized != null) {
      throw onUnauthorized;
    }
    throw ServerFailure();
  }

  Map<String, dynamic> _decode(http.Response response) =>
      jsonDecode(response.body) as Map<String, dynamic>;
}
