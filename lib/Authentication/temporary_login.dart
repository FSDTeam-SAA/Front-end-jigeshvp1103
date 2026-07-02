import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../Home_Page/home_page.dart';
import '../services/dev_auth_session.dart';

class TemporaryLoginScreen extends StatefulWidget {
  const TemporaryLoginScreen({super.key});

  @override
  State<TemporaryLoginScreen> createState() => _TemporaryLoginScreenState();
}

class _TemporaryLoginScreenState extends State<TemporaryLoginScreen> {
  static const String _upperBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _lowerBaseUrl = String.fromEnvironment(
    'baseUrl',
    defaultValue: '',
  );

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email and password are required.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse('${_resolveBaseUrl()}/api/v1/auth/login');
      final response = await http
          .post(
            uri,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final body = _decodeBody(response.body);
      final success =
          response.statusCode >= 200 &&
          response.statusCode < 300 &&
          body['success'] != false;

      if (!success) {
        throw _TemporaryLoginException(
          _readMessage(body) ?? 'Login failed. Please check your credentials.',
        );
      }

      final accessToken = _extractAccessToken(body);
      if (accessToken.isEmpty) {
        throw const _TemporaryLoginException(
          'Login response did not include an access token.',
        );
      }

      DevAuthSession.setLoginSession(
        accessToken: accessToken,
        loginBody: body,
        emailFallback: email,
      );
      await DevAuthSession.save();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } on TimeoutException {
      _showError('Login request timed out. Is the backend running?');
    } on _TemporaryLoginException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError('Unable to login right now. ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _errorMessage = message);
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    final double px = w / 393;
    final double py = h / 852;
    final double formWidth = (w - 54 * px).clamp(300.0, 360.0).toDouble();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 12 * py,
              right: 16 * px,
              child: Image.asset(
                'assets/images/top_corner.png',
                width: 22 * px,
                height: 22 * px,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: 28 * py,
              left: 16 * px,
              child: Image.asset(
                'assets/images/bottom_corner.png',
                width: 20 * px,
                height: 20 * px,
                fit: BoxFit.contain,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 32 * py),
                child: SizedBox(
                  width: formWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 88 * px,
                        height: 88 * px,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 22 * py),
                      Text(
                        'Temporary Login',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sora(
                          fontSize: 24 * px,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2B88CF),
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 8 * py),
                      Text(
                        'Use your email and password.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14 * px,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6A6A6A),
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: 34 * py),
                      _LoginField(
                        controller: _emailController,
                        hintText: 'Email',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        enabled: !_isLoading,
                        px: px,
                      ),
                      SizedBox(height: 14 * py),
                      _LoginField(
                        controller: _passwordController,
                        hintText: 'Password',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        enabled: !_isLoading,
                        px: px,
                        onSubmitted: (_) {
                          if (!_isLoading) _login();
                        },
                        suffix: IconButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20 * px,
                            color: const Color(0xFF6A6A6A),
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _errorMessage == null
                            ? SizedBox(height: 24 * py)
                            : Padding(
                                padding: EdgeInsets.only(top: 12 * py),
                                child: Text(
                                  _errorMessage!,
                                  key: ValueKey(_errorMessage),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12 * px,
                                    color: const Color(0xFFE04F4F),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(height: 18 * py),
                      SizedBox(
                        width: double.infinity,
                        height: 54 * py,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFF2B88CF),
                            disabledBackgroundColor: const Color(0xFF9BCDF3),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(27 * px),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 22 * px,
                                  height: 22 * px,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16 * px,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4 * py,
              left: 8 * px,
              child: IconButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20 * px,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _resolveBaseUrl() {
    if (_upperBaseUrl.isNotEmpty) return _upperBaseUrl;
    if (_lowerBaseUrl.isNotEmpty) return _lowerBaseUrl;
    return 'http://10.0.2.2:5000';
  }

  static Map<String, dynamic> _decodeBody(String rawBody) {
    if (rawBody.trim().isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(rawBody);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } on FormatException {
      throw const _TemporaryLoginException(
        'Login API JSON return korche na. baseUrl backend server e point korche kina check koro.',
      );
    }
  }

  static String _extractAccessToken(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is String && data.trim().isNotEmpty) return data.trim();

    final token = _findStringValue(body, const [
      'accessToken',
      'access_token',
      'token',
      'jwt',
    ]);
    return token.trim();
  }

  static String _findStringValue(dynamic value, List<String> keys) {
    if (value is Map<String, dynamic>) {
      for (final key in keys) {
        final candidate = value[key];
        if (candidate is String && candidate.trim().isNotEmpty) {
          return candidate;
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

  static String? _readMessage(Map<String, dynamic> body) {
    final message = body['message'] ?? body['error'];
    return message is String && message.trim().isNotEmpty
        ? message.trim()
        : null;
  }
}

class _LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final double px;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  const _LoginField({
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.px,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.suffix,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      enabled: enabled,
      onSubmitted: onSubmitted,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14 * px,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF1A1C1E),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14 * px,
          color: const Color(0xFF9A9A9A),
        ),
        prefixIcon: Icon(icon, size: 20 * px, color: const Color(0xFF2B88CF)),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF6FBFF),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * px,
          vertical: 16 * px,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24 * px),
          borderSide: const BorderSide(color: Color(0xFF73C5FF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24 * px),
          borderSide: const BorderSide(color: Color(0xFF2B88CF), width: 1.2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24 * px),
          borderSide: const BorderSide(color: Color(0xFFD8ECFC)),
        ),
      ),
    );
  }
}

class _TemporaryLoginException implements Exception {
  final String message;

  const _TemporaryLoginException(this.message);

  @override
  String toString() => message;
}
