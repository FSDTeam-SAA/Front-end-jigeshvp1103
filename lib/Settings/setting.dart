import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../Authentication/Sign_in.dart';
import '../services/dev_auth_session.dart';

// ═══════════════════════════════════════════════════════════════════
// Settings Screen
// Figma: 3 states –
//   1. Filled  → "Jigesh Padel" in field, checkmark full opacity
//   2. Empty   → "Preferred Name" placeholder, checkmark 0.5 opacity
//   3. Editing → new text typed, checkmark full opacity
// ═══════════════════════════════════════════════════════════════════
class SettingsScreen extends StatefulWidget {
  final String initialKnownName;
  final String displayName;

  const SettingsScreen({
    super.key,
    required this.initialKnownName,
    required this.displayName,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
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

  late TextEditingController _nameController;
  late FocusNode _focusNode;

  late final AnimationController _entranceController;
  late final AnimationController _buttonPressController;
  late final Animation<double> _profileFade;
  late final Animation<double> _cardFade;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _profileSlide;
  late final Animation<Offset> _cardSlide;
  late final Animation<Offset> _buttonSlide;
  late final Animation<double> _buttonPressScale;

  // Live tracking of whether field has text
  bool _hasText = true;
  bool _isLoadingVerifiedName = true;
  bool _isSaving = false;
  bool _isLoggingOut = false;
  String _preferredName = '';
  String _verifiedName = '';

  @override
  void initState() {
    super.initState();
    final initialPreferredName = DevAuthSession.preferredName.isNotEmpty
        ? DevAuthSession.preferredName
        : widget.initialKnownName;
    _nameController = TextEditingController(text: initialPreferredName);
    _focusNode = FocusNode();
    _hasText = initialPreferredName.trim().isNotEmpty;
    _preferredName = initialPreferredName;
    _verifiedName = DevAuthSession.verifiedName.isNotEmpty
        ? DevAuthSession.verifiedName
        : widget.initialKnownName;

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );
    _buttonPressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 170),
    );
    _profileFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.58, curve: Curves.easeOut),
    );
    _cardFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.16, 0.78, curve: Curves.easeOut),
    );
    _buttonFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.32, 1, curve: Curves.easeOut),
    );
    _profileSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0, 0.66, curve: Curves.easeOutCubic),
          ),
        );
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.16, 0.82, curve: Curves.easeOutCubic),
          ),
        );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.32, 1, curve: Curves.easeOutBack),
          ),
        );
    _buttonPressScale = Tween<double>(begin: 1, end: 0.92).animate(
      CurvedAnimation(parent: _buttonPressController, curve: Curves.easeOut),
    );

    // Listen to text changes for real-time UI updates
    _nameController.addListener(_onTextChanged);
    _entranceController.forward();
    _loadVerifiedName();
  }

  void _onTextChanged() {
    final bool nowHasText = _nameController.text.trim().isNotEmpty;
    if (nowHasText != _hasText) {
      setState(() => _hasText = nowHasText);
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onTextChanged);
    _nameController.dispose();
    _focusNode.dispose();
    _entranceController.dispose();
    _buttonPressController.dispose();
    super.dispose();
  }

  Future<void> _loadVerifiedName() async {
    try {
      final body = await _requestSettingsEndpoint(
        'verified-name',
        method: 'GET',
      );
      final verifiedName = _extractName(
        body,
        fallback: widget.initialKnownName,
        keys: const [
          'verifiedName',
          'verified_name',
          'legalName',
          'legal_name',
          'fullName',
          'full_name',
          'name',
          'preferredName',
          'preferred_name',
        ],
      );

      if (!mounted) return;
      DevAuthSession.updateVerifiedName(verifiedName);
      setState(() {
        _verifiedName = verifiedName;
        _isLoadingVerifiedName = false;
      });
    } on _SettingsApiException catch (error) {
      _finishVerifiedNameLoad(error.message);
    } on TimeoutException {
      _finishVerifiedNameLoad('Verified name request timed out.');
    } catch (error) {
      _finishVerifiedNameLoad(error.toString());
    }
  }

  Future<void> _refreshSettings() async {
    FocusScope.of(context).unfocus();
    final preferredName = DevAuthSession.preferredName.isNotEmpty
        ? DevAuthSession.preferredName
        : _preferredName;

    setState(() {
      _preferredName = preferredName;
      _nameController.text = preferredName;
      _hasText = preferredName.trim().isNotEmpty;
      _isLoadingVerifiedName = true;
    });

    await _loadVerifiedName();
  }

  void _finishVerifiedNameLoad(String message) {
    if (!mounted) return;
    setState(() => _isLoadingVerifiedName = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onSave() async {
    final String text = _nameController.text.trim();
    if (text.isEmpty || _isSaving) return;

    HapticFeedback.lightImpact();
    setState(() => _isSaving = true);

    try {
      final body = await _requestSettingsEndpoint(
        'preferred-name',
        method: 'PATCH',
        payload: {'preferredName': text},
      );
      final savedName = _extractName(
        body,
        fallback: text,
        keys: const [
          'preferredName',
          'preferred_name',
          'displayName',
          'display_name',
          'name',
        ],
      );
      DevAuthSession.updatePreferredName(savedName);

      if (!mounted) return;
      setState(() => _preferredName = savedName);
      Navigator.pop(context, savedName);
    } on _SettingsApiException catch (error) {
      _showSaveError(error.message);
    } on TimeoutException {
      _showSaveError('Preferred name request timed out.');
    } catch (error) {
      _showSaveError('Unable to update preferred name. ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSaveError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    HapticFeedback.lightImpact();
    setState(() => _isLoggingOut = true);

    final accessToken = _resolveAccessToken();
    try {
      if (accessToken.isNotEmpty) {
        await http
            .post(
              Uri.parse('${_resolveBaseUrl()}/api/v1/auth/logout'),
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $accessToken',
              },
            )
            .timeout(const Duration(seconds: 15));
      }
    } catch (_) {
      // Local logout should still happen even if the network request fails.
    }

    await DevAuthSession.clear();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => false,
    );
  }

  Future<Map<String, dynamic>> _requestSettingsEndpoint(
    String endpoint, {
    required String method,
    Map<String, dynamic>? payload,
  }) async {
    final baseUrl = _resolveBaseUrl();
    final primaryUri = Uri.parse('$baseUrl/api/settings/$endpoint');

    try {
      return await _requestSettings(
        primaryUri,
        method: method,
        payload: payload,
      );
    } on _SettingsApiException catch (error) {
      if (!error.canRetryWithVersion) rethrow;
    }

    return _requestSettings(
      Uri.parse('$baseUrl/api/v1/settings/$endpoint'),
      method: method,
      payload: payload,
    );
  }

  Future<Map<String, dynamic>> _requestSettings(
    Uri uri, {
    required String method,
    Map<String, dynamic>? payload,
  }) async {
    final accessToken = _resolveAccessToken();
    if (accessToken.isEmpty) {
      throw const _SettingsApiException(
        'Missing access token. Please login first.',
      );
    }

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
      if (payload != null) 'Content-Type': 'application/json',
    };

    final response = switch (method) {
      'PATCH' =>
        await http
            .patch(uri, headers: headers, body: jsonEncode(payload))
            .timeout(const Duration(seconds: 15)),
      _ =>
        await http
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 15)),
    };

    final body = _decodeBody(response.body, uri);
    final failed =
        response.statusCode < 200 ||
        response.statusCode >= 300 ||
        body['success'] == false;

    if (failed) {
      throw _SettingsApiException(
        _readMessage(body) ?? 'Settings request failed.',
        canRetryWithVersion: response.statusCode == 404,
      );
    }

    return body;
  }

  static String _resolveBaseUrl() {
    if (_upperBaseUrl.isNotEmpty) return _upperBaseUrl;
    if (_lowerBaseUrl.isNotEmpty) return _lowerBaseUrl;
    return 'http://10.0.2.2:5000';
  }

  static String _resolveAccessToken() {
    if (_upperAccessToken.isNotEmpty) return _upperAccessToken;
    if (_lowerAccessToken.isNotEmpty) return _lowerAccessToken;
    return DevAuthSession.accessToken.trim();
  }

  static Map<String, dynamic> _decodeBody(String rawBody, Uri uri) {
    if (rawBody.trim().isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(rawBody);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } on FormatException {
      final isHtml = rawBody.trimLeft().startsWith('<');
      throw _SettingsApiException(
        isHtml
            ? 'Settings API HTML return korche (${uri.path}). baseUrl backend e ache kina check koro.'
            : 'Settings API JSON return korche na (${uri.path}).',
        canRetryWithVersion: true,
      );
    }
  }

  static String _extractName(
    Map<String, dynamic> body, {
    required String fallback,
    required List<String> keys,
  }) {
    final data = body['data'];
    if (data is String && data.trim().isNotEmpty) return data.trim();

    final name = _findStringValue(body, keys);

    return name.isNotEmpty ? name : fallback;
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

  static String? _readMessage(Map<String, dynamic> body) {
    final message = body['message'] ?? body['error'];
    return message is String && message.trim().isNotEmpty
        ? message.trim()
        : null;
  }

  // ── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Responsive scaling – Figma canvas 393 × 852
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    final double px = w / 393;
    final double py = h / 852;

    final double safeTop = MediaQuery.of(context).padding.top;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      // resizeToAvoidBottomInset keeps the scaffold from auto-resizing;
      // we handle keyboard offset manually via Stack + Positioned.
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Scrollable content ─────────────────────────────────────
          Positioned.fill(
            bottom: keyboardHeight, // push content up when keyboard shows
            child: SafeArea(
              child: RefreshIndicator(
                color: const Color(0xFF2B88CF),
                onRefresh: _refreshSettings,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * px),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Figma: content starts at Top 226px from screen top
                        SizedBox(height: (226 * py) - safeTop),

                        // ── Profile Section (156 × 144 Hug, Gap 16px) ─────
                        FadeTransition(
                          opacity: _profileFade,
                          child: SlideTransition(
                            position: _profileSlide,
                            child: _buildProfileSection(px, py),
                          ),
                        ),

                        // Figma: parent frame gap = 16px
                        SizedBox(height: 16 * py),

                        // ── Name Edit Card (361 × 128 Hug) ─────────────────
                        FadeTransition(
                          opacity: _cardFade,
                          child: SlideTransition(
                            position: _cardSlide,
                            child: _buildNameEditCard(px, py),
                          ),
                        ),

                        // Figma: parent frame gap = 16px
                        SizedBox(height: 16 * py),

                        // ── Checkmark Save Button (64 × 64) ────────────────
                        FadeTransition(
                          opacity: _buttonFade,
                          child: SlideTransition(
                            position: _buttonSlide,
                            child: _buildCheckmarkButton(px, py),
                          ),
                        ),

                        SizedBox(height: 16 * py),
                        FadeTransition(
                          opacity: _buttonFade,
                          child: SlideTransition(
                            position: _buttonSlide,
                            child: _buildLogoutButton(px, py),
                          ),
                        ),

                        // Bottom breathing room
                        SizedBox(height: 48 * py),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Profile Section – 156 × 144, centered, Gap 16px
  // ══════════════════════════════════════════════════════════════════
  Widget _buildProfileSection(double px, double py) {
    final String profileName = _preferredName.trim().isNotEmpty
        ? _preferredName.trim()
        : widget.displayName;

    return SizedBox(
      width: 260 * px,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Avatar Circle – 80×80, Radius 39px, Border 3px #2D2D2D ──
          Container(
            width: 80 * px,
            height: 80 * px,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(39 * px),
              border: Border.all(color: const Color(0xFF2D2D2D), width: 3 * px),
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                _getInitials(profileName),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28 * px,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
            ),
          ),

          SizedBox(height: 16 * py), // Gap 16px within profile frame
          // ── Display Name + Verified badge ───────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  profileName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18 * px,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1C1E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 4 * px),
              Icon(
                Icons.verified,
                color: const Color(0xFF8E8E93),
                size: 16 * px,
              ),
            ],
          ),

          SizedBox(height: 4 * py),

          // ── "Verified as ..." – 156 Fill × 15 Hug, #888888, 12px ───
          SizedBox(
            width: 260 * px,
            child: Text(
              _isLoadingVerifiedName
                  ? 'Loading verified name...'
                  : 'Verified as $_verifiedName',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12 * px,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF888888),
                height: 1.0, // 100% line height
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Name Edit Card
  // Figma: 361 Fill × 128 Hug, bg #F6FBFF, border 1px #73C5FF,
  //        radius 16px, padding T16 R12 B16 L12, gap 32px
  // ══════════════════════════════════════════════════════════════════
  Widget _buildNameEditCard(double px, double py) {
    return Container(
      width: 361 * px,
      padding: EdgeInsets.only(
        top: 16 * py,
        bottom: 16 * py,
        left: 12 * px,
        right: 12 * px,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FBFF),
        borderRadius: BorderRadius.circular(16 * px),
        border: Border.all(color: const Color(0xFF73C5FF), width: 1 * px),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Instruction text
          Text(
            "Enter the name you\u2019re known by in class.",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14 * px,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A1C1E),
            ),
          ),

          SizedBox(height: 32 * py), // Figma gap: 32px
          // ── Input capsule ─────────────────────────────────────────
          Container(
            height: 48 * py,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24 * px),
              border: Border.all(color: const Color(0xFF73C5FF), width: 1 * px),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16 * px),
            child: Row(
              children: [
                // Text field
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    focusNode: _focusNode,
                    enabled: !_isSaving,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14 * px,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF1A1C1E),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Preferred Name',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14 * px,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFBABABA),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                // Pencil/edit icon – always visible
                _PremiumTap(
                  haptic: true,
                  onTap: () => _focusNode.requestFocus(),
                  child: Icon(
                    Icons.edit_outlined,
                    color: const Color(0xFF1A1C1E),
                    size: 18 * px,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Checkmark Button
  // Figma: 64×64, radius 50px, gradient #58AAE3 → #1F7FC9
  //        Shadow: X0 Y2 Blur8 Spread0 #000000 25%
  // Logic:
  //   • Field has text  → opacity 1.0, tap saves & pops
  //   • Field is empty  → opacity 0.5, tap does nothing
  // ══════════════════════════════════════════════════════════════════
  Widget _buildCheckmarkButton(double px, double py) {
    final bool isEnabled = _hasText && !_isSaving;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _buttonPressController.forward() : null,
      onTapUp: isEnabled ? (_) => _buttonPressController.reverse() : null,
      onTapCancel: isEnabled ? () => _buttonPressController.reverse() : null,
      onTap: isEnabled ? () => _onSave() : null,
      child: ScaleTransition(
        scale: _buttonPressScale,
        child: AnimatedOpacity(
          opacity: isEnabled ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 64 * px,
            height: 64 * px,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF58AAE3), Color(0xFF1F7FC9)],
              ),
              borderRadius: BorderRadius.circular(50 * px),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000), // 25% black
                  offset: Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: _isSaving
                ? SizedBox(
                    width: 22 * px,
                    height: 22 * px,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.check_rounded, color: Colors.white, size: 28 * px),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(double px, double py) {
    return SizedBox(
      height: 44 * py,
      child: TextButton.icon(
        onPressed: _isLoggingOut ? null : _logout,
        icon: _isLoggingOut
            ? SizedBox(
                width: 16 * px,
                height: 16 * px,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFE04F4F),
                ),
              )
            : Icon(
                Icons.logout_rounded,
                size: 18 * px,
                color: const Color(0xFFE04F4F),
              ),
        label: Text(
          'Logout',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14 * px,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFE04F4F),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Utility: extract initials from name
  // ══════════════════════════════════════════════════════════════════
  String _getInitials(String name) {
    if (name.isEmpty) return 'ST';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length > 1 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}

class _SettingsApiException implements Exception {
  final String message;
  final bool canRetryWithVersion;

  const _SettingsApiException(this.message, {this.canRetryWithVersion = false});

  @override
  String toString() => message;
}

class _PremiumTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool haptic;

  const _PremiumTap({
    required this.child,
    required this.onTap,
    this.haptic = false,
  });

  @override
  State<_PremiumTap> createState() => _PremiumTapState();
}

class _PremiumTapState extends State<_PremiumTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 170),
    );
    _scale = Tween<double>(
      begin: 1,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        if (widget.haptic) HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
