import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'role_selection.dart';
import 'temporary_login.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  // Title
  late AnimationController _titleController;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;

  // Subtitle
  late AnimationController _subtitleController;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;

  // Google button
  late AnimationController _googleController;
  late Animation<double> _googleFade;
  late Animation<Offset> _googleSlide;

  // Microsoft button
  late AnimationController _msController;
  late Animation<double> _msFade;
  late Animation<Offset> _msSlide;

  // Corner decorations
  late AnimationController _cornerController;
  late Animation<double> _cornerFade;
  late Animation<double> _cornerScale;

  @override
  void initState() {
    super.initState();

    // ── Title ─────────────────────────────────────────
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _titleFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeOut));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
        );

    // ── Subtitle ──────────────────────────────────────
    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeOut),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _subtitleController,
            curve: Curves.easeOutCubic,
          ),
        );

    // ── Google button ──────────────────────────────────
    _googleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _googleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _googleController, curve: Curves.easeOut),
    );
    _googleSlide =
        Tween<Offset>(begin: const Offset(-0.15, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _googleController, curve: Curves.easeOutBack),
        );

    // ── Microsoft button ───────────────────────────────
    _msController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _msFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _msController, curve: Curves.easeOut));
    _msSlide = Tween<Offset>(begin: const Offset(-0.15, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _msController, curve: Curves.easeOutBack),
        );

    // ── Corner decorations ─────────────────────────────
    _cornerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cornerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cornerController, curve: Curves.easeOut),
    );
    _cornerScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _cornerController, curve: Curves.easeOutBack),
    );

    // ── Staggered start ────────────────────────────────
    _cornerController.forward();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _titleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) _subtitleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 380), () {
      if (mounted) _googleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _msController.forward();
    });
  }

  void _showSchoolEmailDialog(BuildContext context, double px, double py) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7), // 70% black overlay
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * px), // 16px radius
          ),
          child: SizedBox(
            width: 246 * px, // Fixed 246px width
            height: 193 * py, // Fixed 193px height
            child: Padding(
              padding: EdgeInsets.all(8 * px), // 8px padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Warning Icon (weui:error-outlined) ──
                  Container(
                    width: 31 * px, // 31px width
                    height: 31 * px, // 31px height
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6E00).withOpacity(
                        0.1,
                      ), // 10% opacity for soft light orange background
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 17 * px,
                        height: 17 * px,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6E00), // solid orange
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '!',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 12 * px,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * py), // 16px gap
                  // ── Warning Text ──
                  SizedBox(
                    width: 196 * px, // Fixed 196px width
                    height: 63 * py, // Fixed 63px height
                    child: Center(
                      child: Text(
                        'You must use the email address given to you by your school.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14 * px, // 14px font size
                          fontWeight: FontWeight.w400, // 400 Regular
                          color: const Color(0xFFFF6E00), // #FF6E00
                          height: 1.5, // 150% line height
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openTemporaryLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TemporaryLoginScreen()),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _googleController.dispose();
    _msController.dispose();
    _cornerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Figma canvas: 393 × 852 px
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    final double px = w / 393;
    final double py = h / 852;

    final double frameLeft = 27 * px;
    final double frameTop = 308 * py;
    final double frameWidth = 340 * px;
    final double gap = 40 * py;

    final double btnHeight = 56 * py;
    final double btnRadius = 50.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // ── Corner decoration – top right ──────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12 * py,
            right: 16 * px,
            child: FadeTransition(
              opacity: _cornerFade,
              child: ScaleTransition(
                scale: _cornerScale,
                alignment: Alignment.topRight,
                child: Image.asset(
                  'assets/images/top_corner.png',
                  width: 22 * px,
                  height: 22 * px,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // ── Corner decoration – bottom left ────────────────────
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 28 * py,
            left: 16 * px,
            child: FadeTransition(
              opacity: _cornerFade,
              child: ScaleTransition(
                scale: _cornerScale,
                alignment: Alignment.bottomLeft,
                child: Image.asset(
                  'assets/images/bottom_corner.png',
                  width: 20 * px,
                  height: 20 * px,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // ── Main content frame ─────────────────────────────────
          Positioned(
            top: frameTop,
            left: frameLeft,
            width: frameWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Title ──────────────────────────────────────────
                FadeTransition(
                  opacity: _titleFade,
                  child: SlideTransition(
                    position: _titleSlide,
                    child: SizedBox(
                      width: frameWidth,
                      child: Text(
                        'Welcome to Squarle',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sora(
                          fontSize: 24 * px,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2B88CF),
                          height: 1.0,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 8 * py),

                // ── Subtitle ────────────────────────────────────────
                FadeTransition(
                  opacity: _subtitleFade,
                  child: SlideTransition(
                    position: _subtitleSlide,
                    child: SizedBox(
                      width: frameWidth,
                      child: Text(
                        'Log in with your school email',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16 * px,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6A6A6A),
                          height: 1.2, // 120%
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: gap),

                // ── Continue with Google button ─────────────────────
                FadeTransition(
                  opacity: _googleFade,
                  child: SlideTransition(
                    position: _googleSlide,
                    child: _AnimatedSocialButton(
                      icon: 'assets/images/google.png',
                      label: 'Continue with Google',
                      width: frameWidth,
                      height: btnHeight,
                      radius: btnRadius,
                      iconSize: 20 * px,
                      px: px,
                      onTap: () {
                        // TODO: Uncomment below to show school email validation popup
                        // _showSchoolEmailDialog(context, px, py);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RoleSelectionScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(height: 16 * py),

                // ── Continue with Microsoft button ──────────────────
                FadeTransition(
                  opacity: _msFade,
                  child: SlideTransition(
                    position: _msSlide,
                    child: _AnimatedSocialButton(
                      icon: 'assets/images/microsoft.png',
                      label: 'Continue with Microsoft',
                      width: frameWidth,
                      height: btnHeight,
                      radius: btnRadius,
                      iconSize: 20 * px,
                      px: px,
                      onTap: () {
                        // TODO: Uncomment below to show school email validation popup
                        // _showSchoolEmailDialog(context, px, py);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RoleSelectionScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(height: 18 * py),

                _AnimatedSocialButton(
                  icon: 'assets/images/logo.png',
                  label: 'Use temporary login',
                  width: frameWidth,
                  height: 48 * py,
                  radius: btnRadius,
                  iconSize: 18 * px,
                  px: px,
                  onTap: _openTemporaryLogin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated Social Sign-in Button (press scale effect) ───────
class _AnimatedSocialButton extends StatefulWidget {
  final String icon;
  final String label;
  final double width;
  final double height;
  final double radius;
  final double iconSize;
  final double px;
  final VoidCallback onTap;

  const _AnimatedSocialButton({
    required this.icon,
    required this.label,
    required this.width,
    required this.height,
    required this.radius,
    required this.iconSize,
    required this.px,
    required this.onTap,
  });

  @override
  State<_AnimatedSocialButton> createState() => _AnimatedSocialButtonState();
}

class _AnimatedSocialButtonState extends State<_AnimatedSocialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) => _pressController.reverse(),
      onTapCancel: () => _pressController.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _pressScale,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF82C8FF), width: 1.0),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 48 * widget.px),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  widget.icon,
                  width: widget.iconSize,
                  height: widget.iconSize,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 12 * widget.px),
                Text(
                  widget.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16 * widget.px,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF000000),
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
