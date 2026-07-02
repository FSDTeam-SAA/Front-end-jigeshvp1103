import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jigeshvp1103/Add_Class/add_class.dart';
import '../models/class_item.dart';
import '../services/class_service.dart';

// ════════════════════════════════════════════════════════════════════
// SearchScreen  – Figma: canvas 393 × 852 px
// ════════════════════════════════════════════════════════════════════
class SearchScreen extends StatefulWidget {
  /// The list of lists of already added classes for each semester page
  final List<List<ClassItem>> addedClasses;

  /// Full semesters pool: [{'label': String, 'classes': List<ClassItem>}]
  final List<Map<String, dynamic>> semesters;

  const SearchScreen({
    super.key,
    required this.addedClasses,
    required this.semesters,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ClassService _classService = ClassService();
  Timer? _searchDebounce;

  late final AnimationController _entranceController;
  late final Animation<double> _entranceFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<Offset> _contentSlide;
  late final Animation<Offset> _hudSlide;

  /// Grouped results: [{'label': String, 'classes': List<ClassItem>}]
  List<Map<String, dynamic>> _groupedResults = [];
  String _query = '';
  bool _isSearching = false;
  bool _isAdding = false;
  String? _searchError;
  int _searchGeneration = 0;

  /// Currently selected class and its semester label
  ClassItem? _selectedClass;
  String? _selectedSemesterLabel;

  // ── Lifecycle ──────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _entranceFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.82, curve: Curves.easeOut),
    );
    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.20), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.04, 0.58, curve: Curves.easeOutCubic),
          ),
        );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.045), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.18, 0.86, curve: Curves.easeOutCubic),
          ),
        );
    _hudSlide = Tween<Offset>(begin: const Offset(0, 0.20), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.30, 1, curve: Curves.easeOutBack),
          ),
        );
    _searchController.addListener(_onSearchChanged);
    _entranceController.forward();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  // ── Search logic ───────────────────────────────────────────────────
  void _onSearchChanged() {
    final raw = _searchController.text;
    final q = raw.trim();
    _searchGeneration++;

    setState(() {
      _query = raw;
      // Reset selection when query changes
      _selectedClass = null;
      _selectedSemesterLabel = null;
      _searchError = null;

      if (q.isEmpty) {
        _groupedResults = [];
        _isSearching = false;
        return;
      }

      _groupedResults = [];
      _isSearching = true;
    });

    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _searchClasses(q),
    );
  }

  Future<void> _searchClasses(String query) async {
    final generation = ++_searchGeneration;

    try {
      final classes = await _classService.searchClasses(query);
      if (!mounted || generation != _searchGeneration) return;

      setState(() {
        _groupedResults = _groupClassesBySemester(classes);
        _isSearching = false;
      });
    } catch (error) {
      if (!mounted || generation != _searchGeneration) return;

      setState(() {
        _groupedResults = [];
        _searchError = error.toString();
        _isSearching = false;
      });
    }
  }

  Future<void> _refreshSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _groupedResults = [];
        _searchError = null;
        _isSearching = false;
        _selectedClass = null;
        _selectedSemesterLabel = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
      _selectedClass = null;
      _selectedSemesterLabel = null;
    });
    await _searchClasses(query);
  }

  List<Map<String, dynamic>> _groupClassesBySemester(List<ClassItem> classes) {
    final grouped = <String, List<ClassItem>>{};
    for (final classItem in classes) {
      grouped.putIfAbsent(classItem.semesterLabel, () => []).add(classItem);
    }

    return grouped.entries.map((entry) {
      return {'label': entry.key, 'classes': entry.value};
    }).toList();
  }

  // ── Validation logic ───────────────────────────────────────────────
  String? _getValidationError() {
    if (_selectedClass == null || _selectedSemesterLabel == null) return null;

    final addedClasses = widget.addedClasses.expand((classes) => classes);

    // 1. Check if already added
    final isAlreadyAdded = addedClasses.any((classItem) {
      final sameId =
          classItem.id.isNotEmpty && classItem.id == _selectedClass!.id;
      final sameClass =
          classItem.name == _selectedClass!.name &&
          classItem.teacher == _selectedClass!.teacher &&
          classItem.semesterLabel == _selectedSemesterLabel;
      return sameId || sameClass;
    });
    if (isAlreadyAdded) {
      return 'This class is already added to your class list.';
    }

    final semIndex = widget.semesters.indexWhere(
      (s) => s['label'] == _selectedSemesterLabel,
    );
    if (semIndex == -1) return null;

    final addedList = widget.addedClasses[semIndex];

    // 2. Check if list is full (5 items max)
    if (addedList.length >= 5) {
      return 'Your class list for $_selectedSemesterLabel is full.';
    }

    return null;
  }

  Future<void> _addAndPop() async {
    final selectedClass = _selectedClass;
    if (selectedClass == null || _selectedSemesterLabel == null || _isAdding) {
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _isAdding = true);

    try {
      await _classService.addClassToList(selectedClass);
      if (!mounted) return;
      Navigator.pop(context, {'reload': true});
    } catch (error) {
      if (!mounted) return;
      setState(() => _isAdding = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  // ── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Responsive scaling – same system as home_page.dart
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    final double px = w / 393; // Figma canvas width
    final double py = h / 852; // Figma canvas height

    // Figma: search bar top 68px, left 16px, width 361px
    final double headerLeft = 16 * px;
    final double headerTop = 68 * py;
    final double headerWidth = 361 * px;

    // Figma: search input height 48px, close button 48×48
    final double barHeight = 48 * px; // square px to keep aspect-ratio
    final double contentTop = headerTop + barHeight + 16 * py;

    final String? validationError = _getValidationError();
    final bool canAdd =
        _selectedClass != null && validationError == null && !_isAdding;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Search Bar Row ─────────────────────────────────────────
          Positioned(
            top: headerTop,
            left: headerLeft,
            width: headerWidth,
            child: FadeTransition(
              opacity: _entranceFade,
              child: SlideTransition(
                position: _headerSlide,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Search Input – 307px × 48px, radius 47px, #F5F5F5, padding 16px, gap 8px
                    Expanded(
                      child: Container(
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(47 * px),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16 * px),
                        child: Row(
                          children: [
                            // Search icon
                            Icon(
                              Icons.search_rounded,
                              color: const Color(0xFF2D2D2D),
                              size: 20 * px,
                            ),
                            SizedBox(width: 8 * px),
                            // Text field
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14 * px,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Find your class',
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    fontSize: 14 * px,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF888888),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Gap between input and close/checkmark button
                    SizedBox(width: 8 * px),

                    // Action Button (Close or Checkmark) – 48×48, radius 32px
                    _PremiumTap(
                      haptic: true,
                      onTap: () {
                        if (canAdd) {
                          _addAndPop();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48 * px,
                        height: 48 * px,
                        decoration: BoxDecoration(
                          color: canAdd
                              ? const Color(0xFF2B88CF)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(32 * px),
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: _isAdding
                                ? SizedBox(
                                    key: const ValueKey('adding'),
                                    width: 18 * px,
                                    height: 18 * px,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    canAdd
                                        ? Icons.check_rounded
                                        : Icons.close_rounded,
                                    key: ValueKey<bool>(canAdd),
                                    color: canAdd
                                        ? Colors.white
                                        : const Color(0xFF1A1C1E),
                                    size: 20 * px,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content Area ───────────────────────────────────────────
          Positioned(
            top: contentTop,
            left: headerLeft,
            right: headerLeft,
            bottom: 0,
            child: FadeTransition(
              opacity: _entranceFade,
              child: SlideTransition(
                position: _contentSlide,
                child: RefreshIndicator(
                  color: const Color(0xFF2B88CF),
                  onRefresh: _refreshSearch,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: KeyedSubtree(
                      key: ValueKey<String>(
                        '${_query.trim()}_${_groupedResults.length}_$_isSearching',
                      ),
                      child: _buildContent(px, py),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Floating Bottom HUD (Warning + Plus Button) ─────────────
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16 * py,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _entranceFade,
              child: SlideTransition(
                position: _hudSlide,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Floating + Button
                    _PremiumTap(
                      haptic: true,
                      onTap: () async {
                        final result =
                            await Navigator.push<Map<String, dynamic>>(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        AddClassScreen(
                                          semesters: widget.semesters,
                                        ),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                transitionDuration: const Duration(
                                  milliseconds: 250,
                                ),
                              ),
                            );
                        if (result != null && context.mounted) {
                          Navigator.pop(context, result);
                        }
                      },
                      child: Container(
                        width: 48 * px,
                        height: 48 * px,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF58AAE3), Color(0xFF1F7FC9)],
                          ),
                          borderRadius: BorderRadius.circular(50 * px),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40000000),
                              offset: Offset(0, 2),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 24 * px,
                        ),
                      ),
                    ),
                    // Warning Message
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: validationError != null
                          ? Column(
                              key: const ValueKey('warning'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 12 * py),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16 * px,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        color: const Color(0xFFFF8A00),
                                        size: 16 * px,
                                      ),
                                      SizedBox(width: 6 * px),
                                      Flexible(
                                        child: Text(
                                          validationError,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12 * px,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFFFF8A00),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(key: ValueKey('no-warning')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Content builder ────────────────────────────────────────────────
  Widget _buildContent(double px, double py) {
    if (_query.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Text(
            'Search by the course name and instructor',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13 * px,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFBABABA),
              height: 1.5,
            ),
          ),
          SizedBox(height: 520 * py),
        ],
      );
    }

    if (_isSearching) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 420 * py,
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF2B88CF)),
            ),
          ),
        ],
      );
    }

    if (_searchError != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Text(
            _searchError!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14 * px,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFFF5A5A),
            ),
          ),
          SizedBox(height: 520 * py),
        ],
      );
    }

    if (_groupedResults.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Text(
            'No classes found for "$_query"',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14 * px,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF888888),
            ),
          ),
          SizedBox(height: 520 * py),
        ],
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 120 * py),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: _groupedResults.length,
      itemBuilder: (context, sectionIndex) {
        final section = _groupedResults[sectionIndex];
        final label = section['label'] as String;
        final classes = section['classes'] as List<ClassItem>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sectionIndex > 0) SizedBox(height: 16 * py),
            SizedBox(
              width: 361 * px,
              height: 24 * py,
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20 * px,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2B88CF),
                  height: 1.2,
                ),
              ),
            ),
            SizedBox(height: 8 * py),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: classes.length,
              separatorBuilder: (_, index) => SizedBox(height: 8 * py),
              itemBuilder: (context, index) {
                final item = classes[index];
                final isSelected =
                    _selectedClass?.name == item.name &&
                    _selectedSemesterLabel == label;

                return _ResultEntrance(
                  index: sectionIndex * 6 + index,
                  px: px,
                  child: _PremiumTap(
                    haptic: true,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedClass = null;
                          _selectedSemesterLabel = null;
                        } else {
                          _selectedClass = item;
                          _selectedSemesterLabel = label;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16 * px,
                        vertical: 12 * py,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFF4FAFF)
                            : const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(8 * px),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2B88CF)
                              : Colors.transparent,
                          width: 1.5 * px,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14 * px,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1A1C1E),
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 4 * py),
                          Text(
                            item.teacher,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12 * px,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF888888),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
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
      end: 0.94,
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

class _ResultEntrance extends StatelessWidget {
  final int index;
  final double px;
  final Widget child;

  const _ResultEntrance({
    required this.index,
    required this.px,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final int delay = (index * 24).clamp(0, 220);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 330 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10 * px),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
