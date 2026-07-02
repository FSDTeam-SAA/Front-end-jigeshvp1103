import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/class_item.dart';
import 'dev_auth_session.dart';

class ClassService {
  static const String _upperBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _lowerBaseUrl = String.fromEnvironment(
    'baseUrl',
    defaultValue: '',
  );

  static const String _upperAccessToken = String.fromEnvironment(
    'ACCESS_TOKEN',
    defaultValue: '',
  );
  static const String _lowerAccessToken = String.fromEnvironment(
    'access_token',
    defaultValue: '',
  );

  final String baseUrl;
  final String accessToken;
  final http.Client _client;

  ClassService({String? baseUrl, String? accessToken, http.Client? client})
    : baseUrl = _resolveBaseUrl(baseUrl),
      accessToken = _resolveAccessToken(accessToken),
      _client = client ?? http.Client();

  static String _resolveBaseUrl(String? value) {
    final injectedValue = value?.trim();
    if (injectedValue != null && injectedValue.isNotEmpty) {
      return injectedValue;
    }

    if (_upperBaseUrl.isNotEmpty) return _upperBaseUrl;
    if (_lowerBaseUrl.isNotEmpty) return _lowerBaseUrl;

    // Android emulators reach the host machine through 10.0.2.2.
    return 'http://10.0.2.2:5000';
  }

  static String _resolveAccessToken(String? value) {
    final injectedValue = value?.trim();
    if (injectedValue != null && injectedValue.isNotEmpty) {
      return injectedValue;
    }

    if (_upperAccessToken.isNotEmpty) return _upperAccessToken;
    if (_lowerAccessToken.isNotEmpty) return _lowerAccessToken;
    return DevAuthSession.accessToken;
  }

  Future<List<ClassItem>> getMyClasses() async {
    if (accessToken.trim().isEmpty) {
      throw const ClassServiceException(
        'Missing access token. Log in first, or run Flutter with --dart-define=access_token=<token>.',
      );
    }

    final uri = Uri.parse('$baseUrl/api/v1/classes/my-classes');
    final body = await _request(uri, method: 'GET');

    final data = body['data'];
    if (data is! List) return const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(ClassItem.fromClassListJson)
        .toList();
  }

  Future<List<ClassItem>> searchClasses(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return const [];

    final uri = Uri.parse(
      '$baseUrl/api/v1/classes/search',
    ).replace(queryParameters: {'q': trimmedQuery});
    final body = await _request(uri, method: 'GET');
    final data = body['data'];
    if (data is! List) return const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(ClassItem.fromCatalogJson)
        .where((classItem) => classItem.id.isNotEmpty)
        .toList();
  }

  Future<void> addClassToList(ClassItem classItem) async {
    await _request(
      Uri.parse('$baseUrl/api/v1/classes/add'),
      method: 'POST',
      payload: classItem.toAddPayload(),
    );
  }

  Future<void> removeClassFromList(String classListId) async {
    final trimmedId = classListId.trim();
    if (trimmedId.isEmpty) {
      throw const ClassServiceException('Class list id is missing.');
    }

    await _request(
      Uri.parse('$baseUrl/api/v1/classes/my-classes/$trimmedId'),
      method: 'DELETE',
    );
  }

  Future<Map<String, dynamic>> _request(
    Uri uri, {
    required String method,
    Map<String, dynamic>? payload,
  }) async {
    if (accessToken.trim().isEmpty) {
      throw const ClassServiceException(
        'Missing access token. Log in first, or run Flutter with --dart-define=access_token=<token>.',
      );
    }

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
      if (payload != null) 'Content-Type': 'application/json',
    };

    final response = switch (method) {
      'POST' =>
        await _client
            .post(uri, headers: headers, body: jsonEncode(payload))
            .timeout(const Duration(seconds: 15)),
      'DELETE' =>
        await _client
            .delete(uri, headers: headers)
            .timeout(const Duration(seconds: 15)),
      _ =>
        await _client
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 15)),
    };

    final decoded = jsonDecode(response.body);
    final body = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};
    final success = body['success'] == true;
    if (response.statusCode < 200 || response.statusCode >= 300 || !success) {
      throw ClassServiceException(
        body['message'] as String? ?? 'Class request failed.',
      );
    }

    return body;
  }
}

class ClassServiceException implements Exception {
  final String message;

  const ClassServiceException(this.message);

  @override
  String toString() => message;
}
