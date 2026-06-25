import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Table/models/table_thread.dart';
import '../Table/services/table_service.dart';
import 'thread_create_screen.dart';
import 'widgets/new_thread_button.dart';
import 'widgets/thread_list_item.dart';

class ThreadScreen extends StatefulWidget {
  final List<TableThread> threads;
  final String? selectedThreadId;
  final String tableId;
  final String currentUserId;
  final TableService tableService;

  const ThreadScreen({
    super.key,
    required this.threads,
    required this.tableId,
    required this.tableService,
    this.selectedThreadId,
    this.currentUserId = '',
  });

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  static bool _hasAutoShownAssessmentHint = false;

  late List<TableThread> _threads;
  TableThread? _assessmentHintThread;
  String? _markingThreadId;

  @override
  void initState() {
    super.initState();
    _threads = List.of(widget.threads);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeAutoShowAssessmentHint();
    });
  }

  Future<void> _openCreateThread() async {
    final thread = await Navigator.push<TableThread>(
      context,
      MaterialPageRoute(
        builder: (context) => ThreadCreateScreen(
          tableId: widget.tableId,
          tableService: widget.tableService,
        ),
      ),
    );

    if (thread != null && mounted) {
      Navigator.pop(context, thread);
    }
  }

  void _showAssessmentHint(TableThread thread) {
    setState(() => _assessmentHintThread = thread);
  }

  void _maybeAutoShowAssessmentHint() {
    final currentUserId = widget.currentUserId.trim();
    if (!mounted ||
        _hasAutoShownAssessmentHint ||
        currentUserId.isEmpty) {
      return;
    }

    final ownUnresolvedThreads = _threads.where(
      (thread) =>
          thread.createdByUserId.trim() == currentUserId &&
          !thread.assessmentMarked,
    );
    if (ownUnresolvedThreads.isEmpty) return;

    _hasAutoShownAssessmentHint = true;
    _showAssessmentHint(ownUnresolvedThreads.first);
  }

  Future<void> _toggleAssessment() async {
    final thread = _assessmentHintThread;
    if (thread == null || _markingThreadId != null) return;

    setState(() => _markingThreadId = thread.threadId);

    try {
      final assessmentMarked = await widget.tableService.toggleAssessment(
        thread.threadId,
      );
      if (!mounted) return;
      final updated = thread.copyWith(assessmentMarked: assessmentMarked);
      setState(() {
        _threads = _threads
            .map((item) => item.threadId == thread.threadId ? updated : item)
            .toList();
        _assessmentHintThread = null;
        _markingThreadId = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _markingThreadId = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Widget _buildAssessmentOverlay(double px, double py) {
    final thread = _assessmentHintThread;
    if (thread == null) return const SizedBox.shrink();

    final isMarking = _markingThreadId == thread.threadId;
    final threadIndex = _threads.indexWhere(
      (item) => item.threadId == thread.threadId,
    );
    final itemTop = (84 + (threadIndex < 0 ? 0 : threadIndex * 72)) * py;
    final popoverTop = itemTop + (49 * py);
    final iconCenterX = 22 * px + 13 * px + (31 * px / 2);

    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          if (!isMarking) setState(() => _assessmentHintThread = null);
        },
        child: Container(
          color: Colors.black.withValues(alpha: 0.68),
          child: Stack(
            children: [
              Positioned(
                left: 22 * px,
                top: itemTop,
                right: 22 * px,
                child: IgnorePointer(
                  child: Container(
                    constraints: BoxConstraints(minHeight: 56 * py),
                    padding: EdgeInsets.symmetric(
                      horizontal: 13 * px,
                      vertical: 10 * py,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5FBFF),
                      borderRadius: BorderRadius.circular(28 * px),
                      border: Border.all(color: const Color(0xFF222222)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 31 * px,
                          height: 31 * px,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            thread.assessmentMarked
                                ? Icons.check_box
                                : Icons.crop_square,
                            size: 17 * px,
                            color: const Color(0xFF8F8F8F),
                          ),
                        ),
                        SizedBox(width: 14 * px),
                        Expanded(
                          child: Text(
                            thread.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13 * px,
                              height: 1.35,
                              color: const Color(0xFF111111),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 23 * px,
                top: popoverTop,
                child: GestureDetector(
                  onTap: _toggleAssessment,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: (iconCenterX - 23 * px - 7 * px).clamp(
                            0,
                            201 * px,
                          ).toDouble(),
                        ),
                        child: CustomPaint(
                          size: Size(14 * px, 14 * py),
                          painter: _TrianglePainter(),
                        ),
                      ),
                      Container(
                        width: 215 * px,
                        height: 60 * py,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 18 * px),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7 * px),
                        ),
                        child: isMarking
                            ? SizedBox(
                                width: 18 * px,
                                height: 18 * px,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF2A9DF4),
                                ),
                              )
                            : Text(
                                thread.assessmentMarked
                                    ? 'Unmark when the thread needs more work.'
                                    : 'Mark when the thread is resolved.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13 * px,
                                  height: 1.35,
                                  color: const Color(0xFF333333),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    final double px = w / 393;
    final double py = h / 852;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 11 * px, top: 24 * py),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      icon: Icon(Icons.arrow_back_ios_new, size: 24 * px),
                      color: const Color(0xFF222222),
                      tooltip: 'Back',
                    ),
                  ),
                ),
                SizedBox(height: 12 * py),
                Expanded(
                  child: _threads.isEmpty
                      ? Center(
                          child: Text(
                            'No threads yet.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13 * px,
                              color: const Color(0xFF8F8F8F),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            22 * px,
                            0,
                            22 * px,
                            96 * py,
                          ),
                          itemCount: _threads.length,
                          itemBuilder: (context, index) {
                            final thread = _threads[index];
                            return ThreadListItem(
                              thread: thread,
                              selected:
                                  thread.threadId == widget.selectedThreadId,
                              currentUserId: widget.currentUserId,
                              px: px,
                              py: py,
                              onTap: () => Navigator.pop(context, thread),
                              onAssessmentLongPress:
                                  widget.currentUserId.trim().isNotEmpty &&
                                      thread.createdByUserId.trim() ==
                                          widget.currentUserId.trim()
                                  ? () => _showAssessmentHint(thread)
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 52 * py,
              child: Center(
                child: NewThreadButton(
                  px: px,
                  py: py,
                  onPressed: _openCreateThread,
                ),
              ),
            ),
            _buildAssessmentOverlay(px, py),
          ],
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
