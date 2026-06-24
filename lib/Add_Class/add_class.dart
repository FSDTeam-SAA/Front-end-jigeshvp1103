import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AddClassScreen extends StatefulWidget {
  final List<Map<String, dynamic>> semesters;

  const AddClassScreen({super.key, required this.semesters});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  static const double _figmaWidth = 393;
  static const double _figmaHeight = 852;

  late final List<String> _terms;
  late String _selectedTerm;

  @override
  void initState() {
    super.initState();
    _terms = _buildAcademicTerms();
    _selectedTerm = _defaultSelectedTerm(_terms);
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
    return terms.isNotEmpty ? terms.last : 'Winter ${DateTime.now().year}';
  }

  void _onTermTap(String term) {
    if (_selectedTerm == term) return;
    setState(() => _selectedTerm = term);
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
        body: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: LayoutBuilder(
            builder: (context, _) {
              final Size screenSize = MediaQuery.sizeOf(context);
              final double px = screenSize.width / _figmaWidth;
              final double py = screenSize.height / _figmaHeight;
              final double scale = math.min(px, py);

              double x(double value) => value * px;
              double y(double value) => value * py;
              double s(double value) => value * scale;

              return SizedBox.expand(
                child: Stack(
                  children: [
                    Positioned(
                      top: y(80),
                      left: 0,
                      right: 0,
                      child: Text(
                        'Add your class',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: s(16),
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF2D2D2D),
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    Positioned(
                      top: y(134),
                      left: 0,
                      right: 0,
                      child: _ProgressIndicatorRow(
                        activeIndex: 0,
                        px: px,
                        scale: scale,
                      ),
                    ),
                    Positioned(
                      top: y(190),
                      left: x(16),
                      width: x(361),
                      child: Text(
                        'Select the academic term for your class.',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: s(16),
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF2D2D2D),
                          height: 1.5,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    Positioned(
                      top: y(238),
                      left: 0,
                      right: 0,
                      child: Text(
                        'Term',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: s(12),
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF888888),
                          height: 1.25,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    Positioned(
                      top: y(257),
                      left: (screenSize.width - x(173)) / 2,
                      child: _TermPickerCard(
                        width: x(173),
                        height: y(167),
                        radius: s(8),
                        borderWidth: math.max(1.0, s(1)),
                        scale: scale,
                        terms: _terms,
                        selectedTerm: _selectedTerm,
                        onTermTap: _onTermTap,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProgressIndicatorRow extends StatelessWidget {
  final int activeIndex;
  final double px;
  final double scale;

  const _ProgressIndicatorRow({
    required this.activeIndex,
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
        final bool isActive = index == activeIndex;
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
