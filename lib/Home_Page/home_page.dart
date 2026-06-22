import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Entrance Animation Controllers
  late AnimationController _headerController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  late AnimationController _centerTextController;
  late Animation<double> _centerTextFade;
  late Animation<Offset> _centerTextSlide;

  late AnimationController _cornerController;
  late Animation<double> _cornerFade;
  late Animation<double> _cornerScale;

  @override
  void initState() {
    super.initState();

    // ── Header Entrance Animation ──────────────────────
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );

    // ── Center Text Entrance Animation ─────────────────
    _centerTextController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _centerTextFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _centerTextController, curve: Curves.easeOut),
    );
    _centerTextSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _centerTextController, curve: Curves.easeOutCubic),
    );

    // ── Corner Decorations Entrance Animation ──────────
    _cornerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cornerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cornerController, curve: Curves.easeOut),
    );
    _cornerScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _cornerController, curve: Curves.easeOutBack),
    );

    // Start staggered sequence
    _cornerController.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _headerController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _centerTextController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _centerTextController.dispose();
    _cornerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    // Standard scaling factors based on 393x852 design screen
    final double px = w / 393;
    final double py = h / 852;

    // Header Frame parameters from Figma
    // Frame 2147231589: Width 361px, Height 40px (Hug), Top: 68px, Left: 16px
    final double headerWidth = 361 * px;
    final double headerHeight = 40 * py;
    final double headerTop = 68 * py;
    // Align frame horizontally centered with a fallback to 16px left padding
    final double headerLeft = (w - headerWidth) / 2;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
      
          // ── Header Frame (Search + JP Avatar) ──────────────────
          Positioned(
            top: headerTop,
            left: headerLeft,
            width: headerWidth,
            height: headerHeight,
            child: FadeTransition(
              opacity: _headerFade,
              child: SlideTransition(
                position: _headerSlide,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left spacer / logo placeholder to respect the 220px gap
                    SizedBox(width: 49 * px),

                    // Right side icons group
                    Row(
                      children: [
                        // Search Button (40px x 40px)
                        _buildSearchButton(px),

                        SizedBox(width: 12 * px),

                        // JP Profile Avatar (40px x 40px)
                        _buildProfileAvatar(px),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Center Subtext ─────────────────────────────────────
          Center(
            child: FadeTransition(
              opacity: _centerTextFade,
              child: SlideTransition(
                position: _centerTextSlide,
                child: SizedBox(
                  width: 322 * px, // Figma: Width 322px
                  height: 19 * py, // Figma: Height 19px
                  child: Text(
                    'Tap search to find your first class',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16 * px,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF888888), // Figma: #888888 (Subtext)
                      height: 1.2, // Figma: Line height 120%
                      letterSpacing: 0,
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

  // ── Search Button builder ──────────────────────────────────────────
  Widget _buildSearchButton(double px) {
    return GestureDetector(
      onTap: () {
        // Trigger search action
      },
      child: SizedBox(
        width: 40 * px,
        height: 40 * px,
        child: Image.asset(
          'assets/images/search.png',
          width: 40 * px,
          height: 40 * px,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // ── Profile Avatar builder ─────────────────────────────────────────
  Widget _buildProfileAvatar(double px) {
    return Container(
      width: 40 * px,
      height: 40 * px,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF2D2D2D), // Figma: #2D2D2D
          width: 2 * px, // Figma: Border 2px
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20 * px),
          onTap: () {
            // Open profile / settings
          },
          child: Center(
            child: Text(
              'JP',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14 * px,
                fontWeight: FontWeight.w600, // Medium/Semi-bold
                color: const Color(0xFF2D2D2D), // Figma: #2D2D2D
              ),
            ),
          ),
        ),
      ),
    );
  }
}