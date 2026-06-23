import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart'; // To access ClassItem

class SearchScreen extends StatefulWidget {
  final List<ClassItem> allClasses;
  const SearchScreen({super.key, required this.allClasses});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ClassItem> _searchResults = [];
  String _query = '';

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

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _query = _searchController.text;
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = widget.allClasses.where((item) {
          final nameMatch = item.name.toLowerCase().contains(query);
          final teacherMatch = item.teacher.toLowerCase().contains(query);
          return nameMatch || teacherMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double w  = MediaQuery.of(context).size.width;
    final double h  = MediaQuery.of(context).size.height;
    final double px = w / 393;
    final double py = h / 852;

    final double headerLeft  = 16 * px;
    final double headerTop   = 68 * py;
    final double headerWidth = 361 * px;

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
              children: [
                // Search Input Field (fills remaining space after close button)
                Expanded(
                  child: Container(
                    height: 48 * py,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(47 * px),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16 * px),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: const Color(0xFF2D2D2D),
                          size: 20 * px,
                        ),
                        SizedBox(width: 8 * px),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
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

                SizedBox(width: 6 * px),

                // Close Button (48×48)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 48 * px,
                    height: 48 * px,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(32 * px),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.close_rounded,
                        color: const Color(0xFF1A1C1E),
                        size: 20 * px,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Content Area (dynamic) ──────────────────────────────────
          Positioned(
            top: headerTop + 48 * py + 16 * py, // below search bar row with 16px gap
            left: 16 * px,
            right: 16 * px,
            bottom: 0,
            child: _query.isEmpty
                ? Text(
                    'Search by the course name and instructor',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13 * px,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFBABABA),
                      height: 1.5, // 150% line height
                    ),
                  )
                : _searchResults.isEmpty
                    ? Text(
                        'No classes found matching "$_query"',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14 * px,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF888888),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.only(bottom: 40 * py),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, index) => SizedBox(height: 8 * py), // subtle separator gap
                        itemBuilder: (context, index) {
                          final item = _searchResults[index];
                          return Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 16 * px, vertical: 12 * py),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(8 * px), // slightly rounded for premium feel
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}