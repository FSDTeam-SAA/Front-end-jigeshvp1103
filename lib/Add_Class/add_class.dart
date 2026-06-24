import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Home_Page/home_page.dart';

class AddClassScreen extends StatefulWidget {
  final List<Map<String, dynamic>> semesters;

  const AddClassScreen({super.key, required this.semesters});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  static const double _figmaWidth = 393;
  static const double _figmaHeight = 852;

  final TextEditingController _courseTitleController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  late final List<String> _terms;
  late String _selectedTerm;

  int _step = 0;

  @override
  void initState() {
    super.initState();
    _terms = _buildAcademicTerms();
    _selectedTerm = _defaultSelectedTerm(_terms);
    _courseTitleController.addListener(_syncInputState);
    _firstNameController.addListener(_syncInputState);
    _lastNameController.addListener(_syncInputState);
  }

  @override
  void dispose() {
    _courseTitleController.removeListener(_syncInputState);
    _firstNameController.removeListener(_syncInputState);
    _lastNameController.removeListener(_syncInputState);
    _courseTitleController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  List<String> _buildAcademicTerms() {
    final int currentYear = DateTime.now().year;
    const List<String> seasons = ['Fall', 'Winter', 'Spring', 'Summer'];

    return [
      for (int year = 2010; year <= currentYear; year++)
        for (final season in seasons) '$season $year',
    ];
  }

  String _defaultSelectedTerm(List<String> terms) {
    final String currentWinter = 'Winter ${DateTime.now().year}';
    if (terms.contains(currentWinter)) return currentWinter;
    return terms.isNotEmpty ? terms.last : currentWinter;
  }

  void _syncInputState() {
    if (mounted) setState(() {});
  }

  void _onTermTap(String term) {
    if (_selectedTerm == term) return;
    setState(() => _selectedTerm = term);
  }

  bool get _canContinue {
    if (_step == 0) return true;
    if (_step == 1) return _courseTitleController.text.trim().isNotEmpty;
    return _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty;
  }

  int get _activeProgressCount => _step + 1;

  void _onCheckTap() {
    FocusScope.of(context).unfocus();
    if (!_canContinue) return;

    if (_step < 2) {
      setState(() => _step++);
      return;
    }

    final String firstName = _firstNameController.text.trim();
    final String lastName = _lastNameController.text.trim();
    Navigator.pop(context, {
      'semesterLabel': _selectedTerm,
      'classItem': ClassItem(
        name: _courseTitleController.text.trim(),
        teacher: '$firstName $lastName',
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: LayoutBuilder(
              builder: (context, _) {
                final Size screenSize = MediaQuery.sizeOf(context);
                final double px = screenSize.width / _figmaWidth;
                final double py = screenSize.height / _figmaHeight;
                final double scale = math.min(px, py);

                return SizedBox.expand(
                  child: Stack(
                    children: [
                      _buildTitle(scale, py),
                      _buildProgress(px, py, scale),
                      if (_step == 0)
                        _buildTermStep(screenSize, px, py, scale)
                      else if (_step == 1)
                        _buildCourseTitleStep(px, py, scale)
                      else
                        _buildInstructorStep(px, py, scale),
                      _buildCheckButton(px, py, scale),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(double scale, double py) {
    return Positioned(
      top: 80 * py,
      left: 0,
      right: 0,
      child: Text(
        'Add your class',
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF2D2D2D),
          height: 1.2,
          letterSpacing: 0,
        ),
      ),
    );
  }

  Widget _buildProgress(double px, double py, double scale) {
    return Positioned(
      top: 134 * py,
      left: 0,
      right: 0,
      child: _ProgressIndicatorRow(
        activeCount: _activeProgressCount,
        px: px,
        scale: scale,
      ),
    );
  }

  Widget _buildTermStep(Size screenSize, double px, double py, double scale) {
    return Stack(
      children: [
        Positioned(
          top: 190 * py,
          left: 16 * px,
          width: 361 * px,
          child: Text(
            'Select the academic term for your class.',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF2D2D2D),
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
        ),
        Positioned(
          top: 238 * py,
          left: 0,
          right: 0,
          child: Text(
            'Term',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF888888),
              height: 1.25,
              letterSpacing: 0,
            ),
          ),
        ),
        Positioned(
          top: 257 * py,
          left: (screenSize.width - (173 * px)) / 2,
          child: _TermPickerCard(
            width: 173 * px,
            height: 167 * py,
            radius: 8 * scale,
            borderWidth: math.max(0.5, 0.5 * scale),
            scale: scale,
            terms: _terms,
            selectedTerm: _selectedTerm,
            onTermTap: _onTermTap,
          ),
        ),
      ],
    );
  }

  Widget _buildCourseTitleStep(double px, double py, double scale) {
    return Stack(
      children: [
        Positioned(
          top: 186 * py,
          left: 28 * px,
          width: 337 * px,
          child: _CourseTitlePrompt(scale: scale),
        ),
        Positioned(
          top: 249 * py,
          left: 28 * px,
          width: 337 * px,
          child: _PillTextField(
            controller: _courseTitleController,
            hintText: 'Course Title',
            px: px,
            py: py,
            scale: scale,
            textInputAction: TextInputAction.done,
            onChanged: (_) => _syncInputState(),
            onSubmitted: (_) => _onCheckTap(),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructorStep(double px, double py, double scale) {
    return Stack(
      children: [
        Positioned(
          top: 188 * py,
          left: 28 * px,
          width: 337 * px,
          child: Text(
            'Enter the full name of the instructor as shown\non your class schedule.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF2D2D2D),
              height: 1.35,
              letterSpacing: 0,
            ),
          ),
        ),
        Positioned(
          top: 250 * py,
          left: 28 * px,
          width: 337 * px,
          child: _PillTextField(
            controller: _firstNameController,
            hintText: 'First Name',
            px: px,
            py: py,
            scale: scale,
            textInputAction: TextInputAction.next,
            onChanged: (_) => _syncInputState(),
          ),
        ),
        Positioned(
          top: 314 * py,
          left: 28 * px,
          width: 337 * px,
          child: _PillTextField(
            controller: _lastNameController,
            hintText: 'Last Name',
            px: px,
            py: py,
            scale: scale,
            textInputAction: TextInputAction.done,
            onChanged: (_) => _syncInputState(),
            onSubmitted: (_) => _onCheckTap(),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckButton(double px, double py, double scale) {
    return Positioned(
      bottom: math.max(48 * py, MediaQuery.paddingOf(context).bottom + 48 * py),
      left: (MediaQuery.sizeOf(context).width - (64 * px)) / 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _canContinue ? _onCheckTap : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: _canContinue ? 1 : 0,
          child: IgnorePointer(
            ignoring: !_canContinue,
            child: Container(
              width: 64 * px,
              height: 64 * px,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF58AAE3), Color(0xFF1F7FC9)],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 44 * scale,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressIndicatorRow extends StatelessWidget {
  final int activeCount;
  final double px;
  final double scale;

  const _ProgressIndicatorRow({
    required this.activeCount,
    required this.px,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final double itemWidth = 53.33 * px;
    final double itemHeight = 8 * scale;
    final double gap = 8 * px;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final bool isActive = index < activeCount;
        return Container(
          width: itemWidth,
          height: itemHeight,
          margin: EdgeInsets.only(right: index == 2 ? 0 : gap),
          decoration: BoxDecoration(
            color: isActive ? null : const Color(0xFFD9D9D9),
            gradient: isActive
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF58AAE3), Color(0xFF1F7FC9)],
                  )
                : null,
            borderRadius: BorderRadius.circular(16 * scale),
          ),
        );
      }),
    );
  }
}

class _CourseTitlePrompt extends StatelessWidget {
  final double scale;

  const _CourseTitlePrompt({required this.scale});

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = GoogleFonts.plusJakartaSans(
      fontSize: 16 * scale,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF2D2D2D),
      height: 1.5,
      letterSpacing: 0,
    );

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(
            text:
                'Enter the full course name as shown on your\nclass schedule. ',
          ),
          TextSpan(
            text: 'See here',
            style: baseStyle.copyWith(
              decoration: TextDecoration.underline,
              decorationColor: const Color(0xFF2D2D2D),
              decorationThickness: 1,
            ),
          ),
          const TextSpan(text: ' for reference.'),
        ],
      ),
    );
  }
}

class _PillTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final double px;
  final double py;
  final double scale;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const _PillTextField({
    required this.controller,
    required this.hintText,
    required this.px,
    required this.py,
    required this.scale,
    required this.textInputAction,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40 * py,
      child: TextField(
        controller: controller,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        cursorColor: const Color(0xFF1F7FC9),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF2D2D2D),
          height: 1.2,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF8E8E93),
            height: 1.2,
            letterSpacing: 0,
          ),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 17 * px,
            vertical: 10 * py,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20 * scale),
            borderSide: BorderSide(
              color: const Color(0xFF58AAE3),
              width: math.max(0.5, 0.5 * scale),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20 * scale),
            borderSide: BorderSide(
              color: const Color(0xFF58AAE3),
              width: math.max(0.5, 0.5 * scale),
            ),
          ),
        ),
      ),
    );
  }
}

class _TermPickerCard extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  final double borderWidth;
  final double scale;
  final List<String> terms;
  final String selectedTerm;
  final ValueChanged<String> onTermTap;

  const _TermPickerCard({
    required this.width,
    required this.height,
    required this.radius,
    required this.borderWidth,
    required this.scale,
    required this.terms,
    required this.selectedTerm,
    required this.onTermTap,
  });

  @override
  State<_TermPickerCard> createState() => _TermPickerCardState();
}

class _TermPickerCardState extends State<_TermPickerCard> {
  late final FixedExtentScrollController _controller;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    final int initialIndex = widget.terms.indexOf(widget.selectedTerm);
    _selectedIndex = initialIndex == -1 ? 0 : initialIndex;
    _controller = FixedExtentScrollController(initialItem: _selectedIndex);
  }

  @override
  void didUpdateWidget(covariant _TermPickerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTerm != oldWidget.selectedTerm ||
        widget.terms.length != oldWidget.terms.length) {
      final int updatedIndex = widget.terms.indexOf(widget.selectedTerm);
      if (updatedIndex != -1 && updatedIndex != _selectedIndex) {
        _selectedIndex = updatedIndex;
        _controller.jumpToItem(updatedIndex);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFFF6FBFF),
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(
          color: const Color(0xFFE4F3FF),
          width: widget.borderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: ListWheelScrollView.useDelegate(
          controller: _controller,
          itemExtent: 28 * widget.scale,
          physics: const FixedExtentScrollPhysics(),
          perspective: 0.0001,
          diameterRatio: 100,
          overAndUnderCenterOpacity: 1,
          onSelectedItemChanged: (index) {
            setState(() => _selectedIndex = index);
            widget.onTermTap(widget.terms[index]);
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: widget.terms.length,
            builder: (context, index) {
              final String term = widget.terms[index];
              final bool isSelected = index == _selectedIndex;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _controller.animateToItem(
                    index,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                  );
                  setState(() => _selectedIndex = index);
                  widget.onTermTap(term);
                },
                child: Center(
                  child: Text(
                    term,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isSelected
                          ? 16 * widget.scale
                          : 12 * widget.scale,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? const Color(0xFF1F7FC9)
                          : const Color(0xFF8BC9F8),
                      height: 1.25,
                      letterSpacing: 0,
                    ),
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
