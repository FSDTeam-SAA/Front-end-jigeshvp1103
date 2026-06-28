import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class TableMessageInput extends StatefulWidget {
  final bool enabled;
  final bool isSending;
  final double px;
  final double py;
  final ValueChanged<String> onSend;
  final VoidCallback onOpenDrawing;

  const TableMessageInput({
    super.key,
    required this.enabled,
    required this.isSending,
    required this.px,
    required this.py,
    required this.onSend,
    required this.onOpenDrawing,
  });

  @override
  State<TableMessageInput> createState() => _TableMessageInputState();
}

class _TableMessageInputState extends State<TableMessageInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled || widget.isSending) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final px = widget.px;
    final py = widget.py;

    return Container(
      padding: EdgeInsets.fromLTRB(36 * px, 9 * py, 36 * px, 12 * py),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEDEDED))),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 35 * py,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(24 * px),
          ),
          child: Row(
            children: [
              SizedBox(width: 17 * px),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.enabled && !widget.isSending
                    ? widget.onOpenDrawing
                    : null,
                child: SizedBox(
                  width: 28 * px,
                  height: 40 * py,
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(0, 2 * py),
                      child: SvgPicture.asset(
                        'assets/icons/artboard.svg',
                        width: 14 * px,
                        height: 7 * py,
                        colorFilter: ColorFilter.mode(
                          widget.enabled
                              ? const Color(0xFF202020)
                              : const Color(0xFFBDBDBD),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8 * px),
              Container(
                width: 1,
                height: 23 * py,
                color: const Color(0xFFD7D7D7),
              ),
              SizedBox(width: 8 * px),
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled && !widget.isSending,
                  minLines: 1,
                  maxLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: widget.enabled ? 'Text' : 'Unavailable',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13 * px,
                      color: const Color(0xFFA3A3A3),
                    ),
                  ),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13 * px,
                    color: const Color(0xFF222222),
                  ),
                ),
              ),
              if (widget.isSending)
                Padding(
                  padding: EdgeInsets.only(right: 12 * px),
                  child: SizedBox(
                    width: 15 * px,
                    height: 15 * px,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF2A9DF4),
                    ),
                  ),
                )
              else
                IconButton(
                  onPressed: widget.enabled ? _submit : null,
                  icon: Icon(Icons.arrow_upward, size: 18 * px),
                  color: const Color(0xFF2A9DF4),
                  disabledColor: const Color(0xFFBDBDBD),
                  tooltip: 'Send',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
