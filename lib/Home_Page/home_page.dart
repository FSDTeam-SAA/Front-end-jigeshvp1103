import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Class_Entrance/class_entrance.dart';
import '../Settings/setting.dart';
import '../models/class_item.dart';
import '../services/class_service.dart';
import '../services/dev_auth_session.dart';
import 'search.dart';

typedef _ClassItem = ClassItem;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentPage = 0;
  late PageController _pageController;

  List<Map<String, dynamic>> _semesters = [];
  List<List<_ClassItem>> _pages = [];
  bool _isLoadingClasses = true;
  String? _classesError;
  final ClassService _classService = ClassService();

  String _knownName = DevAuthSession.knownName;
  String _displayName = DevAuthSession.displayName;

  late AnimationController _headerController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _syncSessionNames();
    _loadMyClasses();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _headerController,
            curve: Curves.easeOutCubic,
          ),
        );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
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

  Future<void> _loadMyClasses() async {
    setState(() {
      _isLoadingClasses = true;
      _classesError = null;
    });

    try {
      final classes = await _classService.getMyClasses();
      if (!mounted) return;

      final grouped = _groupClassesBySemester(classes);
      setState(() {
        _semesters = grouped;
        _pages = grouped.map<List<_ClassItem>>((semester) {
          return List<_ClassItem>.from(semester['classes'] as List);
        }).toList();
        _currentPage = 0;
        _isLoadingClasses = false;
      });

      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _classesError = error.toString();
        _semesters = [];
        _pages = [];
        _currentPage = 0;
        _isLoadingClasses = false;
      });
    }
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

  Future<bool> _removeClass(int pageIndex, int itemIndex) async {
    final classItem = _pages[pageIndex][itemIndex];

    try {
      await _classService.removeClassFromList(classItem.classListId);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
      return false;
    }

    if (!mounted) return false;
    setState(() {
      _pages[pageIndex].removeAt(itemIndex);
      (_semesters[pageIndex]['classes'] as List).removeAt(itemIndex);
    });
    return true;
  }

  void _openSearch() {
    Navigator.push<Map<String, dynamic>>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SearchScreen(addedClasses: _pages, semesters: _semesters),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    ).then((result) {
      if (result == null) return;
      if (result['reload'] == true) {
        _loadMyClasses();
        return;
      }

      final semesterLabel = result['semesterLabel'] as String;
      final classItem = result['classItem'] as ClassItem;
      final index = _semesters.indexWhere((s) => s['label'] == semesterLabel);

      if (index != -1) {
        setState(() {
          _pages[index].add(classItem);
          (_semesters[index]['classes'] as List).add(classItem);
        });
      }
    });
  }

  void _syncSessionNames() {
    _knownName = DevAuthSession.knownName;
    _displayName = DevAuthSession.displayName;
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    final double px = w / 393;
    final double py = h / 852;

    final double headerLeft = 16 * px;
    final double headerTop = 68 * py;
    final double headerWidth = 361 * px;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: headerTop,
            left: headerLeft,
            width: headerWidth,
            child: FadeTransition(
              opacity: _headerFade,
              child: SlideTransition(
                position: _headerSlide,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: _openSearch,
                      child: Image.asset(
                        'assets/images/search.png',
                        width: 40 * px,
                        height: 40 * px,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 12 * px),
                    GestureDetector(
                      onTap: () {
                        Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(
                              initialKnownName: _knownName,
                              displayName: _displayName,
                            ),
                          ),
                        ).then((newName) {
                          if (newName != null && newName.trim().isNotEmpty) {
                            setState(() {
                              DevAuthSession.updatePreferredName(newName);
                              _displayName = DevAuthSession.displayName;
                              _knownName = newName.trim();
                            });
                          }
                        });
                      },
                      child: _buildProfileAvatar(px),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: headerTop + 40 * py + 16 * py,
            left: headerLeft,
            right: headerLeft,
            bottom: 0,
            child: FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: _buildClassContent(px, py),
              ),
            ),
          ),
          if (_semesters.isNotEmpty)
            Positioned(
              bottom: 36 * py,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _contentFade,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_semesters.length, (i) {
                    final bool isActive = i == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.symmetric(horizontal: 4 * px),
                      width: isActive ? 24 * px : 8 * px,
                      height: 8 * px,
                      decoration: BoxDecoration(
                        color: isActive
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

  Widget _buildClassContent(double px, double py) {
    if (_isLoadingClasses) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2B88CF)),
      );
    }

    if (_classesError != null) {
      return _ClassMessage(
        px: px,
        title: 'Could not load classes',
        message: _classesError!,
        actionLabel: 'Try again',
        onAction: _loadMyClasses,
      );
    }

    if (_semesters.isEmpty) {
      return _ClassMessage(
        px: px,
        title: 'No classes yet',
        message: 'Classes you add will appear here.',
        actionLabel: 'Refresh',
        onAction: _loadMyClasses,
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: _semesters.length,
      onPageChanged: (i) => setState(() => _currentPage = i),
      itemBuilder: (context, pageIndex) {
        final String label = _semesters[pageIndex]['label'];
        final List<_ClassItem> items = _pages[pageIndex];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20 * px,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2B88CF),
                height: 1.2,
              ),
            ),
            SizedBox(height: 12 * py),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: 80 * py),
                itemCount: items.length,
                separatorBuilder: (_, index) => SizedBox(height: 8 * py),
                itemBuilder: (context, i) {
                  return _SwipeToRemoveTile(
                    key: ValueKey(
                      '${pageIndex}_${items[i].classListId}_${items[i].name}_$i',
                    ),
                    item: items[i],
                    px: px,
                    py: py,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ClassEntranceScreen(classItem: items[i]),
                      ),
                    ),
                    onRemove: () => _removeClass(pageIndex, i),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileAvatar(double px) {
    return Container(
      width: 40 * px,
      height: 40 * px,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2D2D2D), width: 1.5 * px),
      ),
      child: Center(
        child: Text(
          _getInitials(_knownName),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14 * px,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D2D2D),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'ST';
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length > 1 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}

class _ClassMessage extends StatelessWidget {
  final double px;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _ClassMessage({
    required this.px,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18 * px,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13 * px,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF888888),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _SwipeToRemoveTile extends StatefulWidget {
  final _ClassItem item;
  final double px;
  final double py;
  final VoidCallback onTap;
  final Future<bool> Function() onRemove;

  const _SwipeToRemoveTile({
    super.key,
    required this.item,
    required this.px,
    required this.py,
    required this.onTap,
    required this.onRemove,
  });

  @override
  State<_SwipeToRemoveTile> createState() => _SwipeToRemoveTileState();
}

class _SwipeToRemoveTileState extends State<_SwipeToRemoveTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _removeController;
  late Animation<double> _removeAnim;

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

  Future<void> _animateRemove() async {
    await _removeController.forward();
    final removed = await widget.onRemove();
    if (!mounted || removed) return;
    await _removeController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final double px = widget.px;
    final double py = widget.py;

    return SizeTransition(
      sizeFactor: _removeAnim,
      axisAlignment: -1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8 * px),
        child: Dismissible(
          key: widget.key!,
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            HapticFeedback.mediumImpact();
            _animateRemove();
            return false;
          },
          background: Container(color: Colors.transparent),
          secondaryBackground: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFCBCB),
              borderRadius: BorderRadius.circular(0 * px),
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20 * px),
            child: Icon(
              Icons.remove_rounded,
              color: const Color(0xFFFF5A5A),
              size: 24 * px,
            ),
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 16 * px,
                vertical: 12 * py,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(8 * px),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.item.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14 * px,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1C1E),
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 4 * py),
                  Text(
                    widget.item.teacher,
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
        ),
      ),
    );
  }
}
