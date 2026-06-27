import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/table_thread.dart';

class TableThreadHeader extends StatelessWidget {
  final TableThread? thread;
  final String? starterMessage;
  final String currentUserId;
  final double px;
  final double py;
  final VoidCallback? onTap;

  const TableThreadHeader({
    super.key,
    required this.thread,
    required this.px,
    required this.py,
    this.currentUserId = '',
    this.starterMessage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = thread?.title ?? 'No thread yet';
    final subtitle = starterMessage?.trim();
    final text = subtitle == null || subtitle.isEmpty ? title : subtitle;
    final currentUserId = this.currentUserId.trim();
    final isOwnThread = thread != null &&
        currentUserId.isNotEmpty &&
        thread!.createdByUserId.trim() == currentUserId;
    final icon = isOwnThread
        ? thread!.assessmentMarked
            ? Icons.check_box
            : Icons.crop_square
        : thread?.hasUnread == true
            ? Icons.radio_button_checked
            : Icons.radio_button_unchecked;
    final iconColor = isOwnThread && thread!.assessmentMarked
        ? const Color(0xFF2A9DF4)
        : thread?.hasUnread == true
            ? const Color(0xFF2A9DF4)
            : const Color(0xFF8F8F8F);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 46 * py),
        padding: EdgeInsets.symmetric(horizontal: 14 * px, vertical: 10 * py),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(28 * px),
        ),
        child: Row(
          children: [
            Container(
              width: 30 * px,
              height: 30 * px,
              decoration: const BoxDecoration(
                color: Color(0xFFE6E6E6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 17 * px,
              ),
            ),
            SizedBox(width: 12 * px),
            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13 * px,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF2B2B2B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
