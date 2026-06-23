import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'search.dart';

// ── Dummy model ────────────────────────────────────────────────────
class ClassItem {
  final String name;
  final String teacher;
  ClassItem({required this.name, required this.teacher});
}

typedef _ClassItem = ClassItem;


// ── Dummy semesters ────────────────────────────────────────────────
final List<Map<String, dynamic>> _semesters = [
  {
    'label': 'Spring 2026',
    'classes': [
      _ClassItem(name: 'Database System', teacher: 'Abernathy, Mr.'),
      _ClassItem(name: 'Climate Change: Global Impact and future...', teacher: 'Abernathy, M.'),
      _ClassItem(name: 'Data Structures and Algorithms', teacher: 'Abernathy, M.'),
      _ClassItem(name: 'Operating Systems', teacher: 'Abernathy, M.'),
      _ClassItem(name: 'Advanced Topics in Distributed Systems and...', teacher: 'Abernathy, M.'),
      _ClassItem(name: 'Advanced Global Environmental Policy...', teacher: 'Abernathy, M.'),
      _ClassItem(name: 'Database System', teacher: 'Abernathy, M.'),
      _ClassItem(name: 'Database System', teacher: 'Abernathy, M.'),
    ],
  },
  {
    'label': 'Spring 2027',
    'classes': [
      _ClassItem(name: 'Database System', teacher: 'Abernathy, M.'),
      _ClassItem(name: 'Climate Change: Global Impact and future...', teacher: 'Abernathy, M.'),
      _ClassItem(name: 'Database System', teacher: 'Abernathy, M.'),
      _ClassItem(name: 'Database System', teacher: 'Abernathy, M.'),
    ],
  },
  {
    'label': 'Fall 2027',
    'classes': [
      _ClassItem(name: 'Database System', teacher: 'Abernathy, M.'),
      _ClassItem(name: 'Operating Systems', teacher: 'Abernathy, M.'),
    ],
  },
];

// ═══════════════════════════════════════════════════════════════════
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // ── Page state ──────────────────────────────────────────────────
  int _currentPage = 0;
  late PageController _pageController;

  // Per-page class lists (mutable, for swipe-to-remove)
  late List<List<_ClassItem>> _pages;

  // ── Entrance animations ─────────────────────────────────────────
  late AnimationController _headerController;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;

  late AnimationController _contentController;
  late Animation<double>   _contentFade;
  late Animation<Offset>   _contentSlide;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _pages = _semesters
        .map<List<_ClassItem>>((s) => List<_ClassItem>.from(s['classes']))
        .toList();

    // ── Header slide-in from top ───────────────────────
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );

    // ── Content fade-up ────────────────────────────────
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _headerController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _removeClass(int pageIndex, int itemIndex) {
    setState(() {
      _pages[pageIndex].removeAt(itemIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double w  = MediaQuery.of(context).size.width;
    final double h  = MediaQuery.of(context).size.height;
    final double px = w / 393;
    final double py = h / 852;

    // Figma: Header top 68px, left 16px, width 361px, height 40px
    final double headerLeft  = 16 * px;
    final double headerTop   = 68 * py;
    final double headerWidth = 361 * px;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          // ── Header (Search + JP Avatar) ───────────────────────────
          Positioned(
            top:   headerTop,
            left:  headerLeft,
            width: headerWidth,
            child: FadeTransition(
              opacity: _headerFade,
              child: SlideTransition(
                position: _headerSlide,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Search icon — 40×40
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => SearchScreen(
                              allClasses: _pages.expand((p) => p).toList(),
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 200),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/search.png',
                        width:  40 * px,
                        height: 40 * px,
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(width: 12 * px),

                    // JP Avatar — 40×40 circle with border
                    _buildProfileAvatar(px),
                  ],
                ),
              ),
            ),
          ),

          // ── Main content (title + list + dots) ───────────────────
          Positioned(
            top:    headerTop + 40 * py + 16 * py,  // below header with 16px gap
            left:   headerLeft,
            right:  headerLeft,
            bottom: 0,
            child: FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _semesters.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, pageIndex) {
                    final String label   = _semesters[pageIndex]['label'];
                    final List<_ClassItem> items = _pages[pageIndex];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Semester label ────────────────────────
                        // Figma: 361×24, Plus Jakarta Sans 600, 20px, #2B88CF, 120% lh
                        Text(
                          label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize:   20 * px,
                            fontWeight: FontWeight.w600,
                            color:      const Color(0xFF2B88CF),
                            height:     1.2,
                          ),
                        ),

                        SizedBox(height: 12 * py),

                        // ── Class list ────────────────────────────
                        Expanded(
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 80 * py),
                            itemCount: items.length,
                            separatorBuilder: (_, index) => SizedBox(height: 0),
                            itemBuilder: (context, i) {
                              return _SwipeToRemoveTile(
                                key: ValueKey('${pageIndex}_${items[i].name}_$i'),
                                item: items[i],
                                px: px,
                                py: py,
                                onRemove: () => _removeClass(pageIndex, i),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // ── Page indicator dots ───────────────────────────────────
          Positioned(
            bottom: 36 * py,
            left:   0,
            right:  0,
            child: FadeTransition(
              opacity: _contentFade,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_semesters.length, (i) {
                  final bool isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin:         EdgeInsets.symmetric(horizontal: 4 * px),
                    width:  isActive ? 24 * px : 8 * px,
                    height: 8 * px,
                    decoration: BoxDecoration(
                      color:        isActive
                          ? const Color(0xFF2B88CF)
                          : const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(4 * px),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── JP Avatar ─────────────────────────────────────────────────────
  Widget _buildProfileAvatar(double px) {
    return Container(
      width:  40 * px,
      height: 40 * px,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF2D2D2D),
          width: 1.5 * px,
        ),
      ),
      child: Center(
        child: Text(
          'JP',
          style: GoogleFonts.plusJakartaSans(
            fontSize:   14 * px,
            fontWeight: FontWeight.w600,
            color:      const Color(0xFF2D2D2D),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Swipe-to-remove tile
// Figma: card bg white, rounded 0, swipe bg #FFCBCB, minus icon red
// Width 447px (overflows left by -54px), Height 62px hug
// ═══════════════════════════════════════════════════════════════════
class _SwipeToRemoveTile extends StatefulWidget {
  final _ClassItem item;
  final double     px;
  final double     py;
  final VoidCallback onRemove;

  const _SwipeToRemoveTile({
    super.key,
    required this.item,
    required this.px,
    required this.py,
    required this.onRemove,
  });

  @override
  State<_SwipeToRemoveTile> createState() => _SwipeToRemoveTileState();
}

class _SwipeToRemoveTileState extends State<_SwipeToRemoveTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _removeController;
  late Animation<double>   _removeAnim;

  @override
  void initState() {
    super.initState();
    _removeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _removeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _removeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _removeController.dispose();
    super.dispose();
  }

  void _animateRemove() {
    _removeController.forward().then((_) => widget.onRemove());
  }

  @override
  Widget build(BuildContext context) {
    final double px = widget.px;
    final double py = widget.py;

    return SizeTransition(
      sizeFactor: _removeAnim,
      axisAlignment: -1,
      child: Dismissible(
        key: widget.key!,
        direction: DismissDirection.endToStart,   // swipe LEFT
        confirmDismiss: (_) async {
          _animateRemove();
          return false; // we handle removal ourselves via animation
        },
        background: Container(color: Colors.transparent),
        secondaryBackground: Container(
          // Figma: bg #FFCBCB, minus icon centered
          color: const Color(0xFFFFCBCB),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20 * px),
          child: Container(
            width:  28 * px,
            height: 28 * px,
            decoration: const BoxDecoration(
              color:  Color(0xFFFF5A5A),
              shape:  BoxShape.circle,
            ),
            child: Icon(
              Icons.remove_rounded,
              color: Colors.white,
              size:  16 * px,
            ),
          ),
        ),
        child: Container(
          width:   double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16 * px, vertical: 10 * py),
          decoration: const BoxDecoration(
            color: Color(0xFFF7F7F7),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize:   14 * px,
                  fontWeight: FontWeight.w500,
                  color:      const Color(0xFF1A1C1E),
                  height:     1.3,
                ),
              ),
              SizedBox(height: 2 * py),
              Text(
                widget.item.teacher,
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
      ),
    );
  }
}