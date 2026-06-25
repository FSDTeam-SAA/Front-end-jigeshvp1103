import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/dev_auth_session.dart';
import '../models/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final double px;
  final double py;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.px,
    required this.py,
  });

  String _timeLabel(DateTime? dateTime) {
    if (dateTime == null) return '';
    final hour = dateTime.toLocal().hour;
    final minute = dateTime.toLocal().minute.toString().padLeft(2, '0');
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    return '$displayHour:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final currentUserPreferredName = DevAuthSession.preferredName.trim();
    final isCurrentUser =
        message.userId.trim().isNotEmpty &&
        message.userId.trim() == DevAuthSession.userId.trim();
    final name = isCurrentUser && currentUserPreferredName.isNotEmpty
        ? currentUserPreferredName
        : message.userName?.trim().isNotEmpty == true
            ? message.userName!.trim()
            : 'Member';
    final timeLabel = _timeLabel(message.createdAt);

    return Padding(
      padding: EdgeInsets.only(bottom: 22 * py),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 58 * px),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13 * px,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF212121),
                          ),
                        ),
                      ),
                      SizedBox(width: 5 * px),
                      Icon(
                        Icons.check_circle,
                        size: 9 * px,
                        color: const Color(0xFF9A9A9A),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 9 * py),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 48 * px,
                      child: Text(
                        timeLabel,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10 * px,
                          color: const Color(0xFF969696),
                        ),
                      ),
                    ),
                    SizedBox(width: 10 * px),
                    Expanded(
                      child: message.type == 'whiteboard'
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8 * px),
                              child: Container(
                                width: 230,
                                height: 230,
                                color: Colors.white,
                                child: Image.network(
                                  message.content,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      padding: EdgeInsets.all(12 * px),
                                      color: const Color(0xFFF5F5F5),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Unable to load drawing.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13 * px,
                                          color: const Color(0xFF777777),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          : Text(
                              message.content,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13 * px,
                                height: 1.35,
                                color: const Color(0xFF2D2D2D),
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
