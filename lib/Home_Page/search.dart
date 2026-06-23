import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';

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

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  /// Grouped results: [{'label': String, 'classes': List<ClassItem>}]
  List<Map<String, dynamic>> _groupedResults = [];
  String _query = '';

  /// Currently selected class and its semester label
  ClassItem? _selectedClass;
  String? _selectedSemesterLabel;

  // ── Lifecycle ──────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // ── Search logic ───────────────────────────────────────────────────
  void _onSearchChanged() {
    final raw = _searchController.text;
    final q   = raw.trim().toLowerCase();

    setState(() {
      _query = raw;
      // Reset selection when query changes
      _selectedClass = null;
      _selectedSemesterLabel = null;

      if (q.isEmpty) {
        _groupedResults = [];
        return;
      }

      _groupedResults = [];
      for (final semester in widget.semesters) {
        final label   = semester['label'] as String;
        final classes = semester['classes'] as List<ClassItem>;

        final matched = classes.where((item) {
          return item.name.toLowerCase().contains(q) ||
              item.teacher.toLowerCase().contains(q);
        }).toList();

        if (matched.isNotEmpty) {
          _groupedResults.add({'label': label, 'classes': matched});
        }
      }
    });
  }

  // ── Validation logic ───────────────────────────────────────────────
  String? _getValidationError() {
    if (_selectedClass == null || _selectedSemesterLabel == null) return null;

    final semIndex = widget.semesters.indexWhere((s) => s['label'] == _selectedSemesterLabel);
    if (semIndex == -1) return null;

    final addedList = widget.addedClasses[semIndex];

    // 1. Check if already added
    final isAlreadyAdded = addedList.any((c) => c.name == _selectedClass!.name);
    if (isAlreadyAdded) {
      return 'This class is already added to your class list.';
    }

    // 2. Check if list is full (5 items max)
    if (addedList.length >= 5) {
      return 'Your class list for $_selectedSemesterLabel is full.';
    }

    return null;
  }

  void _addAndPop() {
    if (_selectedClass != null && _selectedSemesterLabel != null) {
      Navigator.pop(context, {
        'semesterLabel': _selectedSemesterLabel,
        'classItem': _selectedClass,
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Responsive scaling – same system as home_page.dart
    final double w  = MediaQuery.of(context).size.width;
    final double h  = MediaQuery.of(context).size.height;
    final double px = w / 393; // Figma canvas width
    final double py = h / 852; // Figma canvas height

    // Figma: search bar top 68px, left 16px, width 361px
    final double headerLeft  = 16 * px;
    final double headerTop   = 68 * py;
    final double headerWidth = 361 * px;

    // Figma: search input height 48px, close button 48×48
    final double barHeight  = 48 * px; // square px to keep aspect-ratio
    final double contentTop = headerTop + barHeight + 16 * py;

    final String? validationError = _getValidationError();
    final bool canAdd = _selectedClass != null && validationError == null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          // ── Search Bar Row ─────────────────────────────────────────
          Positioned(
            top:   headerTop,
            left:  headerLeft,
            width: headerWidth,
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
                              fontSize:   14 * px,
                              fontWeight: FontWeight.w400,
                              color:      Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText:  'Find your class',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize:   14 * px,
                                fontWeight: FontWeight.w400,
                                color:      const Color(0xFF888888),
                              ),
                              border:         InputBorder.none,
                              isDense:        true,
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
                GestureDetector(
                  onTap: () {
                    if (canAdd) {
                      _addAndPop();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width:  48 * px,
                    height: 48 * px,
                    decoration: BoxDecoration(
                      color:        canAdd ? const Color(0xFF2B88CF) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(32 * px),
                    ),
                    child: Center(
                      child: Icon(
                        canAdd ? Icons.check_rounded : Icons.close_rounded,
                        color: canAdd ? Colors.white : const Color(0xFF1A1C1E),
                        size:  20 * px,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Content Area ───────────────────────────────────────────
          Positioned(
            top:    contentTop,
            left:   headerLeft,
            right:  headerLeft,
            bottom: 0,
            child: _buildContent(px, py),
          ),

          // ── Floating Bottom HUD (Warning + Plus Button) ─────────────
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16 * py,
            left:   0,
            right:  0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating + Button
                if (_query.isNotEmpty && _groupedResults.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      if (canAdd) {
                        _addAndPop();
                      }
                    },
                    child: Container(
                      width:  48 * px,
                      height: 48 * px,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin:  Alignment.topLeft,
                          end:    Alignment.bottomRight,
                          colors: [Color(0xFF58AAE3), Color(0xFF1F7FC9)],
                        ),
                        borderRadius: BorderRadius.circular(50 * px),
                        boxShadow: const [
                          BoxShadow(
                            color:       Color(0x40000000), // #000000 at 25%
                            offset:      Offset(0, 2),
                            blurRadius:  8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size:  24 * px,
                      ),
                    ),
                  ),
                
                // Warning Message
                if (validationError != null) ...[
                  SizedBox(height: 12 * py),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * px),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: const Color(0xFFFF8A00),
                          size:  16 * px,
                        ),
                        SizedBox(width: 6 * px),
                        Flexible(
                          child: Text(
                            validationError,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize:   12 * px,
                              fontWeight: FontWeight.w400,
                              color:      const Color(0xFFFF8A00),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Content builder ────────────────────────────────────────────────
  Widget _buildContent(double px, double py) {
    // Empty state – hint text
    if (_query.isEmpty) {
      return Text(
        'Search by the course name and instructor',
        style: GoogleFonts.plusJakartaSans(
          fontSize:   13 * px,
          fontWeight: FontWeight.w400,
          color:      const Color(0xFFBABABA),
          height:     1.5, // 150% – Figma spec
        ),
      );
    }

    // No results
    if (_groupedResults.isEmpty) {
      return Text(
        'No classes found for "$_query"',
        style: GoogleFonts.plusJakartaSans(
          fontSize:   14 * px,
          fontWeight: FontWeight.w400,
          color:      const Color(0xFF888888),
        ),
      );
    }

    // Grouped results list
    return ListView.builder(
      padding:        EdgeInsets.only(bottom: 120 * py),
      physics:        const BouncingScrollPhysics(),
      itemCount:      _groupedResults.length,
      itemBuilder: (context, sectionIndex) {
        final section = _groupedResults[sectionIndex];
        final label   = section['label'] as String;
        final classes = section['classes'] as List<ClassItem>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section gap (not on first section)
            if (sectionIndex > 0) SizedBox(height: 16 * py),

            // Semester label
            SizedBox(
              width:  361 * px,
              height: 24 * py,
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize:   20 * px,
                  fontWeight: FontWeight.w600,
                  color:      const Color(0xFF2B88CF),
                  height:     1.2,
                ),
              ),
            ),

            SizedBox(height: 8 * py),

            // Class cards
            ListView.separated(
              shrinkWrap: true,
              physics:    const NeverScrollableScrollPhysics(),
              itemCount:  classes.length,
              separatorBuilder: (_, index) => SizedBox(height: 8 * py),
              itemBuilder: (context, index) {
                final item = classes[index];
                final isSelected = _selectedClass?.name == item.name &&
                                   _selectedSemesterLabel == label;

                return GestureDetector(
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
                    duration: const Duration(milliseconds: 200),
                    width:   double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * px,
                      vertical:   12 * py,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF4FAFF) : const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(8 * px),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF2B88CF) : Colors.transparent,
                        width: 1.5 * px,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize:       MainAxisSize.min,
                      children: [
                        // Class name
                        Text(
                          item.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize:   14 * px,
                            fontWeight: FontWeight.w500,
                            color:      const Color(0xFF1A1C1E),
                            height:     1.3,
                          ),
                        ),
                        SizedBox(height: 4 * py),
                        // Teacher name
                        Text(
                          item.teacher,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize:   12 * px,
                            fontWeight: FontWeight.w400,
                            color:      const Color(0xFF888888),
                            height:     1.3,
                          ),
                        ),
                      ],
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