import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Home_Page/home_page.dart';

class DateOfBirthScreen extends StatefulWidget {
  const DateOfBirthScreen({super.key});

  @override
  State<DateOfBirthScreen> createState() => _DateOfBirthScreenState();
}

class _DateOfBirthScreenState extends State<DateOfBirthScreen>
    with TickerProviderStateMixin {
  int _selectedDay = 15;
  int _selectedMonth = 10;
  int _selectedYear = 2005;

  bool _isUnder13() {
    final DateTime now = DateTime.now();
    final DateTime birthDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age < 13;
  }


  // Avatar entrance
  late AnimationController _avatarController;
  late Animation<double> _avatarFade;
  late Animation<double> _avatarScale;

  // Avatar float (continuous)
  late AnimationController _avatarFloatController;
  late Animation<double> _avatarFloat;

  // Avatar rings pulse (continuous)
  late AnimationController _ringsController;
  late Animation<double> _ringsScale;

  // Title
  late AnimationController _titleController;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;

  // Per-picker stagger
  late List<AnimationController> _pickerControllers;
  late List<Animation<double>> _pickerFades;
  late List<Animation<double>> _pickerScales;

  // Button
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

    // ── Avatar entrance ────────────────────────────────
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

    // ── Avatar float (continuous) ──────────────────────
    _avatarFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _avatarFloat = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _avatarFloatController, curve: Curves.easeInOut),
    );

    // ── Rings pulse (continuous) ───────────────────────
    _ringsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _ringsScale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _ringsController, curve: Curves.easeInOut),
    );

    // ── Title ──────────────────────────────────────────
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
    );

    // ── Per-picker stagger (3 pickers) ─────────────────
    _pickerControllers = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 550),
      ),
    );
    _pickerFades = _pickerControllers.map((c) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeOut),
      );
    }).toList();
    _pickerScales = _pickerControllers.map((c) {
      return Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeOutBack),
      );
    }).toList();

    // ── Button ─────────────────────────────────────────
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
      if (mounted) {
        _avatarController.forward().then((_) {
          _avatarFloatController.repeat(reverse: true);
          _ringsController.repeat(reverse: true);
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) _titleController.forward();
    });
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: 380 + i * 100), () {
        if (mounted) _pickerControllers[i].forward();
      });
    }
    Future.delayed(const Duration(milliseconds: 750), () {
      if (mounted) _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _avatarFloatController.dispose();
    _ringsController.dispose();
    _titleController.dispose();
    for (final c in _pickerControllers) {
      c.dispose();
    }
    _buttonController.dispose();
    _cornerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    final double px = w / 393;
    final double py = h / 852;

    final double frameWidth  = 348 * px;
    final double frameLeft   = (w - frameWidth) / 2;
    final double frameTop    = 204 * py;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [

          // ── Corner decoration – top right ──────────────────────
          Positioned(
            top:   MediaQuery.of(context).padding.top + 12 * py,
            right: 16 * px,
            child: FadeTransition(
              opacity: _cornerFade,
              child: ScaleTransition(
                scale: _cornerScale,
                alignment: Alignment.topRight,
                child: Image.asset(
                  'assets/images/top_corner.png',
                  width:  22 * px,
                  height: 22 * px,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // ── Corner decoration – bottom left ────────────────────
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 28 * py,
            left:   16 * px,
            child: FadeTransition(
              opacity: _cornerFade,
              child: ScaleTransition(
                scale: _cornerScale,
                alignment: Alignment.bottomLeft,
                child: Image.asset(
                  'assets/images/bottom_corner.png',
                  width:  20 * px,
                  height: 20 * px,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // ── Main Content Frame ─────────────────────────────────
          Positioned(
            top:    frameTop,
            left:   frameLeft,
            width:  frameWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // ── Top Header Section ─────────────────────────────
                Column(
                  children: [

                    FadeTransition(
                      opacity: _avatarFade,
                      child: ScaleTransition(
                        scale: _avatarScale,
                        child: SizedBox(
                          width:  106 * px,
                          height: 106 * px,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [

                              // Floating + pulsing outer rings
                              AnimatedBuilder(
                                animation: Listenable.merge([
                                  _avatarFloat,
                                  _ringsScale,
                                ]),
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, _avatarFloat.value),
                                    child: Transform.scale(
                                      scale: _ringsScale.value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
                                  width:  106 * px,
                                  height: 106 * px,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDFF1FF).withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Container(
                                    width:  86 * px,
                                    height: 86 * px,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDFF1FF).withValues(alpha: 0.55),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),

                              // Static inner circle — only float, no pulse
                              AnimatedBuilder(
                                animation: _avatarFloat,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, _avatarFloat.value),
                                    child: child,
                                  );
                                },
                                child: Container(
                                  width:  65 * px,
                                  height: 65 * px,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFDFF1FF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/calender.png',
                                      width:  28 * px,
                                      height: 28 * px,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                            'What is your date of birth?',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize:      16 * px,
                              fontWeight:    FontWeight.w400,
                              color:         const Color(0xFF2D2D2D),
                              height:        1.4,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 48 * py),

                // ── Date Pickers Row ───────────────────────────────
                SizedBox(
                  width: 324 * px,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      // Day Picker
                      FadeTransition(
                        opacity: _pickerFades[0],
                        child: ScaleTransition(
                          scale: _pickerScales[0],
                          child: _buildPickerColumn(
                            label:        'Day',
                            items:        List.generate(31, (i) => i + 1),
                            initialValue: _selectedDay,
                            px: px,
                            py: py,
                            onChanged: (val) => setState(() => _selectedDay = val),
                          ),
                        ),
                      ),

                      // Month Picker
                      FadeTransition(
                        opacity: _pickerFades[1],
                        child: ScaleTransition(
                          scale: _pickerScales[1],
                          child: _buildPickerColumn(
                            label:        'Month',
                            items:        List.generate(12, (i) => i + 1),
                            initialValue: _selectedMonth,
                            isMonth:      true,
                            px: px,
                            py: py,
                            onChanged: (val) => setState(() => _selectedMonth = val),
                          ),
                        ),
                      ),

                      // Year Picker
                      FadeTransition(
                        opacity: _pickerFades[2],
                        child: ScaleTransition(
                          scale: _pickerScales[2],
                          child: _buildPickerColumn(
                            label:        'Year',
                            items:        List.generate(100, (i) => DateTime.now().year - i).reversed.toList(),
                            initialValue: _selectedYear,
                            px: px,
                            py: py,
                            onChanged: (val) => setState(() => _selectedYear = val),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Warning message
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  height: _isUnder13() ? 52 * py : 0,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: 16 * py),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: _isUnder13() ? 1.0 : 0.0,
                          child: Container(
                            width: 348 * px,
                            padding: EdgeInsets.symmetric(horizontal: 8 * px, vertical: 8 * py),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(4 * px),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: const Color(0xFFFF6E00),
                                  size: 16 * px,
                                ),
                                SizedBox(width: 8 * px),
                                Expanded(
                                  child: Text(
                                    'You must be at least 13 years of age to use Squarle.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize:   14 * px,
                                      fontWeight: FontWeight.w400,
                                      color:      const Color(0xFFFF6E00),
                                      height:     1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 48 * py),

                // ── Check Button ───────────────────────────────────
                FadeTransition(
                  opacity: _buttonFade,
                  child: ScaleTransition(
                    scale: _buttonScale,
                    child: _buildCheckButton(px, py),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerColumn({
    required String label,
    required List<int> items,
    required int initialValue,
    bool isMonth = false,
    required double px,
    required double py,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize:   14 * px,
            fontWeight: FontWeight.w400,
            color:      const Color(0xFF6A6A6A),
          ),
        ),
        SizedBox(height: 8 * px),
        _WheelPickerBox(
          items:        items,
          initialValue: initialValue,
          isMonth:      isMonth,
          px:           px,
          py:           py,
          onChanged:    onChanged,
        ),
      ],
    );
  }

  Widget _buildCheckButton(double px, double py) {
    final bool isEligible = !_isUnder13();
    return _AnimatedCheckButton(
      onTap: isEligible
          ? () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
                (route) => false,
              );
            }
          : null,
      px: px,
    );
  }
}

// ── Custom Wheel Picker Box Widget ─────────────────────────────────
class _WheelPickerBox extends StatefulWidget {
  final List<int> items;
  final int initialValue;
  final bool isMonth;
  final double px;
  final double py;
  final ValueChanged<int> onChanged;

  const _WheelPickerBox({
    required this.items,
    required this.initialValue,
    this.isMonth = false,
    required this.px,
    required this.py,
    required this.onChanged,
  });

  @override
  State<_WheelPickerBox> createState() => _WheelPickerBoxState();
}

class _WheelPickerBoxState extends State<_WheelPickerBox>
    with SingleTickerProviderStateMixin {
  late FixedExtentScrollController _controller;
  late int _selectedIndex;

  // Selected item bounce on scroll
  late AnimationController _selectBounceController;
  late Animation<double> _selectBounce;

  @override
  void initState() {
    super.initState();
    final idx = widget.items.indexOf(widget.initialValue);
    _selectedIndex = idx != -1 ? idx : 0;
    _controller = FixedExtentScrollController(initialItem: _selectedIndex);

    _selectBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _selectBounce = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.18).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.18, end: 1.0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 50,
      ),
    ]).animate(_selectBounceController);
  }

  @override
  void dispose() {
    _controller.dispose();
    _selectBounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double px = widget.px;

    return Container(
      width:  86.67 * px,
      height: 144 * px,
      decoration: BoxDecoration(
        color: const Color(0xFFF6FBFF),
        border: Border.all(
          color: const Color(0xFF2B88CF).withValues(alpha: 0.05),
          width: 1 * px,
        ),
        borderRadius: BorderRadius.circular(8 * px),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8 * px),
        child: ListWheelScrollView.useDelegate(
          controller:   _controller,
          itemExtent:   28 * px,
          physics:      const FixedExtentScrollPhysics(),
          perspective:  0.003,
          diameterRatio: 1.5,
          onSelectedItemChanged: (index) {
            setState(() => _selectedIndex = index);
            widget.onChanged(widget.items[index]);
            // Bounce the selected item
            _selectBounceController.forward(from: 0.0);
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: widget.items.length,
            builder: (context, index) {
              final int    val    = widget.items[index];
              final String valStr = widget.isMonth
                  ? val.toString().padLeft(2, '0')
                  : val.toString();

              final int distance = (index - _selectedIndex).abs();

              double     fontSize   = 16 * px;
              FontWeight fontWeight = FontWeight.w400;
              Color      textColor  = const Color(0xFF1F7FC9);

              if (distance == 0) {
                fontSize   = 16 * px;
                fontWeight = FontWeight.w600;
                textColor  = const Color(0xFF1F7FC9);
              } else if (distance == 1) {
                fontSize  = 14 * px;
                textColor = const Color(0xFF1F7FC9).withValues(alpha: 0.55);
              } else if (distance == 2) {
                fontSize  = 12 * px;
                textColor = const Color(0xFF1F7FC9).withValues(alpha: 0.25);
              } else {
                fontSize  = 10 * px;
                textColor = const Color(0xFF1F7FC9).withValues(alpha: 0.10);
              }

              // Only wrap selected item with bounce
              if (distance == 0) {
                return AnimatedBuilder(
                  animation: _selectBounce,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _selectBounce.value,
                      child: child,
                    );
                  },
                  child: Center(
                    child: Text(
                      valStr,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize:   fontSize,
                        fontWeight: fontWeight,
                        color:      textColor,
                      ),
                    ),
                  ),
                );
              }

              return Center(
                child: Text(
                  valStr,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize:   fontSize,
                    fontWeight: fontWeight,
                    color:      textColor,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Animated Check Button ──────────────────────────────────────────
class _AnimatedCheckButton extends StatefulWidget {
  final VoidCallback? onTap;
  final double px;

  const _AnimatedCheckButton({required this.onTap, required this.px});

  @override
  State<_AnimatedCheckButton> createState() => _AnimatedCheckButtonState();
}

class _AnimatedCheckButtonState extends State<_AnimatedCheckButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.94).animate(
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
    final bool isEnabled = widget.onTap != null;

    return GestureDetector(
      onTapDown:   isEnabled ? (_) => _pressController.forward() : null,
      onTapUp:     isEnabled ? (_) => _pressController.reverse() : null,
      onTapCancel: isEnabled ? ()  => _pressController.reverse() : null,
      onTap:       widget.onTap,
      child: ScaleTransition(
        scale: _pressScale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width:  64 * widget.px,
          height: 64 * widget.px,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isEnabled ? null : const Color(0xFF9BCDF3),
            gradient: isEnabled
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end:   Alignment.bottomCenter,
                    colors: [
                      Color(0xFF58AAE3),
                      Color(0xFF1F7FC9),
                    ],
                  )
                : null,
            boxShadow: isEnabled
                ? [
                    const BoxShadow(
                      color:      Color(0x3D1F7FC9),
                      blurRadius: 12,
                      offset:     Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size:  32 * widget.px,
            ),
          ),
        ),
      ),
    );
  }
}