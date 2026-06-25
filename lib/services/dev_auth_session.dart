import 'dart:convert';

class DevAuthSession {
  static const String defaultAccessToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2YTMyMTY5OThjYTFmYmU3ZDNkN2MwNzAiLCJlbWFpbCI6InN0dWRlbnQxQGdtYWlsLmNvbSIsInJvbGUiOiJzdHVkZW50IiwiaWF0IjoxNzgyMzc1NTg2LCJleHAiOjE3ODI5ODAzODZ9.xCLB5nbe7nEUoV_goebu8qhHQiQ1v0kiyW71i73yf0I';

  static String _accessToken = '';
  static String _email = '';
  static String _preferredName = '';
  static String _verifiedName = '';
  static String _displayName = '';

  static String get accessToken => _accessToken;
  static String get email => _email;
  static String get preferredName => _preferredName;
  static String get verifiedName => _verifiedName;

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
    _email = '';
    _preferredName = '';
    _verifiedName = '';
    _displayName = '';
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
    final email = _findStringValue(value, const ['email', 'schoolEmail']);
    if (email.isNotEmpty) _email = email;

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
