import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  String _selectedRole = 'Student'; // Default selection

  // Animation controllers
  late AnimationController _avatarController;
  late Animation<double> _avatarFade;
  late Animation<double> _avatarScale;

  late AnimationController _titleController;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;

  late AnimationController _optionsController;
  late Animation<double> _optionsFade;
  late Animation<Offset> _optionsSlide;

  late AnimationController _buttonController;
  late Animation<double> _buttonFade;
  late Animation<double> _buttonScale;

  // Corner decorations
  late AnimationController _cornerController;
  late Animation<double> _cornerFade;
  late Animation<double> _cornerScale;

  @override
  void initState() {
    super.initState();

    // ── Avatar Animation ───────────────────────────────
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _avatarFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.easeOut),
    );
    _avatarScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.easeOutBack),
    );

    // ── Title Animation ────────────────────────────────
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

    // ── Options Animation ──────────────────────────────
    _optionsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _optionsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _optionsController, curve: Curves.easeOut),
    );
    _optionsSlide =
        Tween<Offset>(begin: const Offset(-0.1, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _optionsController,
            curve: Curves.easeOutBack,
          ),
        );

    // ── Button Animation ───────────────────────────────
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );
    _buttonScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutBack),
    );

    // ── Corner Decorations ─────────────────────────────
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

    // ── Staggered Start ────────────────────────────────
    _cornerController.forward();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _avatarController.forward();
    });
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) _titleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 380), () {
      if (mounted) _optionsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _titleController.dispose();
    _optionsController.dispose();
    _buttonController.dispose();
    _cornerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Figma Canvas: 393 × 852 px
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    final double px = w / 393;
    final double py = h / 852;

    // Main frame position based on Figma: Top=204, Left=27, Width=340, Height=444
    final double frameLeft = 27 * px;
    final double frameTop = 204 * py;
    final double frameWidth = 340 * px;
    final double frameHeight = 444 * py;

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

          // ── Main Content Frame (Height: 444px, justify: space-between) ──
          Positioned(
            top: frameTop,
            left: frameLeft,
            width: frameWidth,
            height: frameHeight,
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Distribute height evenly
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Top Header Section (Avatar + Text) ────────────────
                Column(
                  children: [
                    // Concentric Circular Avatar Container
                    FadeTransition(
                      opacity: _avatarFade,
                      child: ScaleTransition(
                        scale: _avatarScale,
                        child: Container(
                          width: 106 * px,
                          height: 106 * px,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF1FF).withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            width: 86 * px,
                            height: 86 * px,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDFF1FF).withOpacity(0.55),
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              width: 65 * px, // Figma: Fixed 56px
                              height: 65 * px, // Figma: Fixed 56px
                              decoration: const BoxDecoration(
                                color: Color(0xFFDFF1FF), // Figma: #DFF1FF
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/person_icon.png',
                                  width: 17.5 * px,
                                  height: 19.5 * px,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24 * py),

                    // Title
                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: SizedBox(
                          width: frameWidth,
                          child: Text(
                            'What is your role at your school?',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16 * px, // 16px size
                              fontWeight: FontWeight.w400, // Regular (400)
                              color: const Color(
                                0xFF2D2D2D,
                              ), // #2D2D2D (secondary)
                              height: 1.4, // 120% line height
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10 * py),
                // ── Options Section (Student, Instructor, Other) ──────
                FadeTransition(
                  opacity: _optionsFade,
                  child: SlideTransition(
                    position: _optionsSlide,
                    child: Column(
                      children: [
                        _buildRoleOption('Student', px, py),
                        SizedBox(height: 12 * px),
                        _buildRoleOption('Instructor', px, py),
                        SizedBox(height: 12 * px),
                        _buildRoleOption('Other', px, py),
                        
                        // Conditionally visible warning message
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: _selectedRole != 'Student' ? 34 * py : 0,
                          curve: Curves.easeInOut,
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                SizedBox(height: 16 * py),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      color: const Color(0xFFFF6E00), // #FF6E00 warning color
                                      size: 16 * px,
                                    ),
                                    SizedBox(width: 8 * px),
                                    Text(
                                      'Squarle is intended for student use only.',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14 * px,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFFFF6E00),
                                        height: 1.0, // 100% line height
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Check Button Section ─────────────────────────────
                Padding(
                  padding: EdgeInsets.only(top: 26 * py),
                  child: FadeTransition(
                    opacity: _buttonFade,
                    child: ScaleTransition(
                      scale: _buttonScale,
                      child: _buildCheckButton(px, py),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Role Option Widget ─────────────────────────────────────────────
  Widget _buildRoleOption(String role, double px, double py) {
    final bool isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 340 * px, // Figma: Fill (340px)
        height: 40 * px, // Figma: Fixed (40px) - Scaled with px to preserve aspect ratio
        padding: EdgeInsets.symmetric(
          horizontal: 16 * px,
        ), // Figma: Padding Left/Right 16px
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF73C5FF), // Figma: #73C5FF border
            width: 0.5 * px, // Figma: Border 0.5px
          ),
          borderRadius: BorderRadius.circular(
            20 * px, // Exactly half of 40px height for a perfect pill shape
          ), // Figma: Radius 50px (pill)
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF73C5FF).withOpacity(0.15),
                    blurRadius: 8 * px,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Custom Radio Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18 * px,
              height: 18 * px,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1F7FC9) // Selected border blue
                      : const Color(0xFF73C5FF), // Unselected border light blue
                  width: 1.5 * px,
                ),
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 10 * px : 0,
                  height: isSelected ? 10 * px : 0,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F7FC9), // Selected dot solid blue
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8 * px), // Figma: Gap 8px
            Text(
              role,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16 * px,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF1A1C1E)
                    : const Color(0xFF6A6A6A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Check Button ───────────────────────────────────────────
  Widget _buildCheckButton(double px, double py) {
    final bool isStudent = _selectedRole == 'Student';
    return _AnimatedCheckButton(
      onTap: isStudent
          ? () {
              // Go to next page or perform submission
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Selected Role: $_selectedRole',
                    style: GoogleFonts.plusJakartaSans(),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          : null,
      px: px,
    );
  }
}

// ── Animated Check Button with scale on press ──────────────────────
class _AnimatedCheckButton extends StatefulWidget {
  final VoidCallback? onTap;
  final double px;

  const _AnimatedCheckButton({required this.onTap, required this.px});

  @override
  State<_AnimatedCheckButton> createState() => _AnimatedCheckButtonState();
}

class _AnimatedCheckButtonState extends State<_AnimatedCheckButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _btnPressController;
  late Animation<double> _btnPressScale;

  @override
  void initState() {
    super.initState();
    _btnPressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _btnPressScale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _btnPressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _btnPressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onTap != null;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _btnPressController.forward() : null,
      onTapUp: isEnabled ? (_) => _btnPressController.reverse() : null,
      onTapCancel: isEnabled ? () => _btnPressController.reverse() : null,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _btnPressScale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 64 * widget.px, // Figma: Width 64px
          height: 64 * widget.px, // Figma: Height 64px
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isEnabled ? null : const Color(0xFF9BCDF3), // Solid disabled color
            gradient: isEnabled
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF58AAE3), // Figma: #58AAE3
                      Color(0xFF1F7FC9), // Figma: #1F7FC9
                    ],
                  )
                : null,
            boxShadow: isEnabled
                ? [
                    const BoxShadow(
                      color: Color(0x3D1F7FC9),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 32 * widget.px,
            ),
          ),
        ),
      ),
    );
  }
}
