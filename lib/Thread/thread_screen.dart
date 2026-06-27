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
  final bool canParticipate;

  const ThreadScreen({
    super.key,
    required this.threads,
    required this.tableId,
    required this.tableService,
    this.canParticipate = true,
    this.selectedThreadId,
    this.currentUserId = '',
  });

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  late List<TableThread> _threads;
  String? _markingThreadId;

  @override
  void initState() {
    super.initState();
    _threads = List.of(widget.threads);
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

  bool _canMarkAssessment(TableThread thread) {
    final currentUserId = widget.currentUserId.trim();
    return widget.canParticipate &&
        currentUserId.isNotEmpty &&
        thread.createdByUserId.trim() == currentUserId &&
        !thread.assessmentMarked &&
        _markingThreadId == null;
  }

  Future<void> _markAssessment(TableThread thread) async {
    if (!_canMarkAssessment(thread) || _markingThreadId != null) return;

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
                              onAssessmentTap: _canMarkAssessment(thread)
                                  ? () => _markAssessment(thread)
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            ),
            if (widget.canParticipate)
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
          ],
        ),
      ),
    );
  }
}
