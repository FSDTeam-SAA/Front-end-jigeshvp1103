import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../services/dev_auth_session.dart';
import '../models/chat_message.dart';
import '../models/chat_thread_detail.dart';
import '../models/table_detail.dart';
import '../models/table_thread.dart';

class TableService {
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

  TableService({String? baseUrl, String? accessToken, http.Client? client})
      : baseUrl = _resolveBaseUrl(baseUrl),
        accessToken = _resolveAccessToken(accessToken),
        _client = client ?? http.Client();

  Future<TableDetail> getTable(String sessionId, String tableId) async {
    final body = await _request(
      Uri.parse('$baseUrl/api/v1/squarle/$sessionId/table/$tableId'),
      method: 'GET',
    );
    return TableDetail.fromJson(body);
  }

  Future<ChatThreadDetail> getThread(String threadId) async {
    final body = await _request(
      Uri.parse('$baseUrl/api/v1/chat/threads/$threadId'),
      method: 'GET',
    );
    return ChatThreadDetail.fromJson(body);
  }

  Future<ChatMessage> sendTextMessage(String threadId, String content) async {
    final body = await _request(
      Uri.parse('$baseUrl/api/v1/chat/messages'),
      method: 'POST',
      payload: {
        'threadId': threadId,
        'type': 'text',
        'content': content,
      },
    );
    final data = body['data'];
    return ChatMessage.fromJson(
      data is Map<String, dynamic> ? data : <String, dynamic>{},
    );
  }

  Future<ChatMessage> sendWhiteboardMessage(
    String threadId,
    Uint8List imageBytes,
  ) async {
    if (accessToken.trim().isEmpty) {
      throw const TableServiceException(
        'Missing access token. Run Flutter with --dart-define=access_token=<token>.',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/v1/chat/messages'),
    )
      ..headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      })
      ..fields['threadId'] = threadId
      ..fields['type'] = 'whiteboard'
      ..fields['content'] = 'whiteboard'
      ..files.add(
        http.MultipartFile.fromBytes(
          'whiteboard',
          imageBytes,
          filename: 'drawing.png',
        ),
      );

    final streamedResponse = await _client.send(request).timeout(
          const Duration(seconds: 30),
        );
    final response = await http.Response.fromStream(streamedResponse);
    final decoded = jsonDecode(response.body);
    final body = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    final success = body['success'] == true;

    if (response.statusCode < 200 || response.statusCode >= 300 || !success) {
      throw TableServiceException(
        body['message'] as String? ?? 'Unable to send drawing.',
      );
    }

    final data = body['data'];
    return ChatMessage.fromJson(
      data is Map<String, dynamic> ? data : <String, dynamic>{},
    );
  }

  Future<TableThread> createThread({
    required String tableId,
    required String title,
    required String starterMessage,
  }) async {
    final body = await _request(
      Uri.parse('$baseUrl/api/v1/chat/threads'),
      method: 'POST',
      payload: {
        'tableId': tableId,
        'title': title,
        'starterMessage': starterMessage,
      },
    );
    final data = body['data'];
    final dataJson = data is Map<String, dynamic> ? data : <String, dynamic>{};
    final thread = dataJson['thread'];
    final threadJson = thread is Map<String, dynamic> ? thread : dataJson;

    return TableThread.fromJson(threadJson);
  }

  Future<bool> toggleAssessment(String threadId) async {
    final body = await _request(
      Uri.parse('$baseUrl/api/v1/chat/threads/$threadId/assessment'),
      method: 'PATCH',
    );
    final data = body['data'];
    final dataJson = data is Map<String, dynamic> ? data : <String, dynamic>{};
    return dataJson['assessmentMarked'] == true;
  }

  String get currentUserId {
    final tokenUserId = _currentUserIdFromToken(accessToken);
    if (tokenUserId.isNotEmpty) return tokenUserId;
    return DevAuthSession.userId.trim();
  }

  Future<Map<String, dynamic>> _request(
    Uri uri, {
    required String method,
    Map<String, dynamic>? payload,
  }) async {
    if (accessToken.trim().isEmpty) {
      throw const TableServiceException(
        'Missing access token. Run Flutter with --dart-define=access_token=<token>.',
      );
    }

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
      if (payload != null) 'Content-Type': 'application/json',
    };

    final response = switch (method) {
      'POST' => await _client
          .post(uri, headers: headers, body: jsonEncode(payload))
          .timeout(const Duration(seconds: 15)),
      'PATCH' => await _client
          .patch(
            uri,
            headers: headers,
            body: payload == null ? null : jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15)),
      _ => await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15)),
    };

    final decoded = jsonDecode(response.body);
    final body = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    final success = body['success'] == true;

    if (response.statusCode < 200 || response.statusCode >= 300 || !success) {
      throw TableServiceException(
        body['message'] as String? ?? 'Unable to connect to table.',
      );
    }

    return body;
  }

  static String _resolveBaseUrl(String? value) {
    final injectedValue = value?.trim();
    if (injectedValue != null && injectedValue.isNotEmpty) return injectedValue;
    if (_upperBaseUrl.isNotEmpty) return _upperBaseUrl;
    if (_lowerBaseUrl.isNotEmpty) return _lowerBaseUrl;
    return 'http://10.0.2.2:5000';
  }

  static String _resolveAccessToken(String? value) {
    final injectedValue = value?.trim();
    if (injectedValue != null && injectedValue.isNotEmpty) return injectedValue;
    if (_upperAccessToken.isNotEmpty) return _upperAccessToken;
    if (_lowerAccessToken.isNotEmpty) return _lowerAccessToken;
    return DevAuthSession.accessToken;
  }

  static String _currentUserIdFromToken(String token) {
    final parts = token.split('.');
    if (parts.length < 2) return '';

    try {
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) return '';

      return (decoded['userId'] ??
              decoded['_id'] ??
              decoded['id'] ??
              decoded['sub'] ??
              '')
          .toString();
    } catch (_) {
      return '';
    }
  }
}

class TableServiceException implements Exception {
  final String message;

  const TableServiceException(this.message);

  @override
  String toString() => message;
}
