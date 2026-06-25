import 'dart:convert';

class DevAuthSession {
  static const String defaultAccessToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2YTMyMTY5OThjYTFmYmU3ZDNkN2MwNzAiLCJlbWFpbCI6InN0dWRlbnQxQGdtYWlsLmNvbSIsInJvbGUiOiJzdHVkZW50IiwiaWF0IjoxNzgyMzc1NTg2LCJleHAiOjE3ODI5ODAzODZ9.xCLB5nbe7nEUoV_goebu8qhHQiQ1v0kiyW71i73yf0I';

  static String _accessToken = '';
  static String _refreshToken = '';
  static String _userId = '';
  static String _email = '';
  static String _role = '';
  static String _preferredName = '';
  static String _verifiedName = '';
  static String _displayName = '';
  static DevAuthUser? _user;

  static String get accessToken => _accessToken;
  static String get refreshToken => _refreshToken;
  static String get userId => _userId;
  static String get email => _email;
  static String get role => _role;
  static String get preferredName => _preferredName;
  static String get verifiedName => _verifiedName;
  static DevAuthUser? get user => _user;

  static String get knownName => _firstNonEmpty([
    _preferredName,
    _verifiedName,
    _displayName,
    _nameFromEmail(_email),
    'Student',
  ]);

  static String get displayName => _firstNonEmpty([
    _displayName,
    _verifiedName,
    _preferredName,
    _nameFromEmail(_email),
    'Student',
  ]);

  static void setAccessToken(String value) {
    _accessToken = value.trim();
    _applyTokenPayload(_accessToken);
  }

  static void setLoginSession({
    required String accessToken,
    required Map<String, dynamic> loginBody,
    String? emailFallback,
  }) {
    setAccessToken(accessToken);
    _refreshToken = _findStringValue(loginBody, const [
      'refreshToken',
      'refresh_token',
    ]);
    _applyUserJson(loginBody);
    _applyProfileJson(loginBody);
    if (_email.isEmpty && emailFallback != null) {
      _email = emailFallback.trim();
    }
  }

  static void updatePreferredName(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) _preferredName = trimmed;
  }

  static void updateVerifiedName(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) _verifiedName = trimmed;
  }

  static void clear() {
    _accessToken = '';
    _refreshToken = '';
    _userId = '';
    _email = '';
    _role = '';
    _preferredName = '';
    _verifiedName = '';
    _displayName = '';
    _user = null;
  }

  static void _applyTokenPayload(String token) {
    final parts = token.split('.');
    if (parts.length < 2) return;

    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final decoded = jsonDecode(payload);
      _applyProfileJson(decoded);
    } catch (_) {
      // Some dev tokens may not be JWTs. Keep the explicit login response data.
    }
  }

  static void _applyProfileJson(dynamic value) {
    final userId = _findStringValue(value, const ['_id', 'userId', 'id']);
    if (userId.isNotEmpty) _userId = userId;

    final email = _findStringValue(value, const ['email', 'schoolEmail']);
    if (email.isNotEmpty) _email = email;

    final role = _findStringValue(value, const ['role']);
    if (role.isNotEmpty) _role = role;

    final preferredName = _findStringValue(value, const [
      'preferredName',
      'preferred_name',
    ]);
    if (preferredName.isNotEmpty) _preferredName = preferredName;

    final displayName = _findStringValue(value, const [
      'displayName',
      'display_name',
      'username',
      'userName',
      'nickname',
    ]);
    if (displayName.isNotEmpty) _displayName = displayName;

    final joinedName = _joinedName(value);
    final verifiedName = _firstNonEmpty([
      _findStringValue(value, const [
        'verifiedName',
        'verified_name',
        'legalName',
        'legal_name',
        'fullName',
        'full_name',
        'name',
      ]),
      joinedName,
    ]);
    if (verifiedName.isNotEmpty) _verifiedName = verifiedName;
  }

  static void _applyUserJson(Map<String, dynamic> loginBody) {
    final data = loginBody['data'];
    final dataJson = data is Map<String, dynamic> ? data : loginBody;
    final user = dataJson['user'];
    if (user is! Map<String, dynamic>) return;

    _user = DevAuthUser.fromJson(user);
    _applyProfileJson(user);
  }

  static String _joinedName(dynamic value) {
    final firstName = _findStringValue(value, const [
      'firstName',
      'first_name',
    ]);
    final lastName = _findStringValue(value, const ['lastName', 'last_name']);
    return [
      firstName,
      lastName,
    ].where((part) => part.trim().isNotEmpty).join(' ').trim();
  }

  static String _findStringValue(dynamic value, List<String> keys) {
    if (value is Map<String, dynamic>) {
      for (final key in keys) {
        final candidate = value[key];
        if (candidate is String && candidate.trim().isNotEmpty) {
          return candidate.trim();
        }
      }

      for (final child in value.values) {
        final match = _findStringValue(child, keys);
        if (match.isNotEmpty) return match;
      }
    } else if (value is List) {
      for (final child in value) {
        final match = _findStringValue(child, keys);
        if (match.isNotEmpty) return match;
      }
    }

    return '';
  }

  static String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }

  static String _nameFromEmail(String value) {
    final trimmed = value.trim();
    if (!trimmed.contains('@')) return trimmed;
    return trimmed.split('@').first;
  }
}

class DevAuthUser {
  final String id;
  final String oauthProvider;
  final String email;
  final String domain;
  final String verifiedName;
  final String preferredName;
  final int preferredNameChangeCount;
  final DateTime? dob;
  final String role;
  final bool isOnboarded;
  final String accountStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> rawJson;

  const DevAuthUser({
    required this.id,
    required this.oauthProvider,
    required this.email,
    required this.domain,
    required this.verifiedName,
    required this.preferredName,
    required this.preferredNameChangeCount,
    required this.dob,
    required this.role,
    required this.isOnboarded,
    required this.accountStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.rawJson,
  });

  factory DevAuthUser.fromJson(Map<String, dynamic> json) {
    return DevAuthUser(
      id: (json['_id'] ?? json['id'] ?? json['userId'] ?? '').toString(),
      oauthProvider: (json['oauthProvider'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      domain: (json['domain'] ?? '').toString(),
      verifiedName: (json['verifiedName'] ?? '').toString(),
      preferredName: (json['preferredName'] ?? '').toString(),
      preferredNameChangeCount:
          int.tryParse('${json['preferredNameChangeCount'] ?? 0}') ?? 0,
      dob: DateTime.tryParse('${json['dob'] ?? ''}'),
      role: (json['role'] ?? '').toString(),
      isOnboarded: json['isOnboarded'] == true,
      accountStatus: (json['accountStatus'] ?? '').toString(),
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
      updatedAt: DateTime.tryParse('${json['updatedAt'] ?? ''}'),
      rawJson: Map<String, dynamic>.from(json),
    );
  }
}
