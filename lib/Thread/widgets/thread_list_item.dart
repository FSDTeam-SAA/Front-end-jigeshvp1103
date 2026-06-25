import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Table/models/table_thread.dart';

class ThreadListItem extends StatefulWidget {
  final TableThread thread;
  final bool selected;
  final String currentUserId;
  final double px;
  final double py;
  final VoidCallback onTap;
  final VoidCallback? onAssessmentLongPress;

  const ThreadListItem({
    super.key,
    required this.thread,
    required this.selected,
    this.currentUserId = '',
    required this.px,
    required this.py,
    required this.onTap,
    this.onAssessmentLongPress,
  });

  @override
  State<ThreadListItem> createState() => _ThreadListItemState();
}

class _ThreadListItemState extends State<ThreadListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _glow = CurvedAnimation(parent: _glowController, curve: Curves.easeInOut);
    _syncGlow();
  }

  @override
  void didUpdateWidget(covariant ThreadListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncGlow();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _syncGlow() {
    if (widget.thread.hasUnread && !widget.selected) {
      if (!_glowController.isAnimating) {
        _glowController.repeat(reverse: true);
      }
    } else {
      _glowController.stop();
      _glowController.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final px = widget.px;
    final py = widget.py;
    final thread = widget.thread;
    final selected = widget.selected;
    final currentUserId = widget.currentUserId.trim();
    final isOwnThread =
        currentUserId.isNotEmpty && thread.createdByUserId.trim() == currentUserId;
    final canMarkAssessment =
        isOwnThread && widget.onAssessmentLongPress != null;
    final assessmentIconColor = thread.assessmentMarked
        ? const Color(0xFF2A9DF4)
        : const Color(0xFF909090);
    final threadStateIconColor = selected || thread.hasUnread
        ? const Color(0xFF2A9DF4)
        : const Color(0xFF909090);
    final borderColor = selected
        ? const Color(0xFF2A9DF4)
        : thread.assessmentMarked
            ? const Color(0xFF8F8F8F)
            : Colors.transparent;

    return Padding(
      padding: EdgeInsets.only(bottom: 16 * py),
      child: AnimatedBuilder(
        animation: _glow,
        builder: (context, child) {
          return GestureDetector(
            onTap: widget.onTap,
            child: Container(
              constraints: BoxConstraints(minHeight: 56 * py),
              padding: EdgeInsets.symmetric(
                horizontal: 13 * px,
                vertical: 10 * py,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFF5FBFF)
                    : thread.assessmentMarked
                        ? const Color(0xFFFBFBFB)
                        : const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(28 * px),
                border: Border.all(color: borderColor),
                boxShadow: thread.hasUnread && !selected
                    ? [
                        BoxShadow(
                          color: Color.lerp(
                            const Color(0x002A9DF4),
                            const Color(0x662A9DF4),
                            _glow.value,
                          )!,
                          blurRadius: 12 + (8 * _glow.value),
                          spreadRadius: 1 + (2 * _glow.value),
                        ),
                      ]
                    : const [],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onLongPress:
                        canMarkAssessment ? widget.onAssessmentLongPress : null,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 31 * px,
                      height: 31 * px,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFE7F4FE)
                            : const Color(0xFFEDEDED),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isOwnThread
                            ? thread.assessmentMarked
                                ? Icons.check_box
                                : Icons.crop_square
                            : selected || thread.hasUnread
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                        size: 17 * px,
                        color: isOwnThread
                            ? assessmentIconColor
                            : threadStateIconColor,
                      ),
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
                        color: selected
                            ? const Color(0xFF303030)
                            : const Color(0xFF3A3A3A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
