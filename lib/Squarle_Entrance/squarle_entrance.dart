import 'package:flutter/material.dart';

import '../Class_Entrance/models/squarle_join_result.dart';
import '../Class_Entrance/services/squarle_service.dart';
import '../Table/table_screen.dart';
import 'models/squarle_table.dart';
import 'widgets/squarle_bottom_controls.dart';
import 'widgets/squarle_notice_dialog.dart';
import 'widgets/squarle_table_field.dart';

class SquarleEntranceScreen extends StatefulWidget {
  final SquarleJoinResult joinResult;

  const SquarleEntranceScreen({super.key, required this.joinResult});

  @override
  State<SquarleEntranceScreen> createState() => _SquarleEntranceScreenState();
}

class _SquarleEntranceScreenState extends State<SquarleEntranceScreen> {
  final SquarleService _squarleService = SquarleService();
  bool _isLeaving = false;

  @override
  void initState() {
    super.initState();
  }

  void _showNotice(String message, SquarleNoticeTone tone) {
    final size = MediaQuery.of(context).size;
    final px = size.width / 393;
    final py = size.height / 852;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) {
        return SquarleNoticeDialog(
          message: message,
          tone: tone,
          px: px,
          py: py,
        );
      },
    );
  }

  void _handleTableTap(SquarleTable table) {
    final sessionId = widget.joinResult.sessionId;
    final tableId = table.id.trim();
    final isPlaceholder =
        tableId.isEmpty ||
        tableId.startsWith('fallback_') ||
        tableId.startsWith('table_');

    if (sessionId == null || sessionId.isEmpty || isPlaceholder) {
      _showNotice('Table is not available yet.', SquarleNoticeTone.orange);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TableScreen(
          sessionId: sessionId,
          tableId: table.id,
          tableNumber: table.tableNumber,
        ),
      ),
    );
  }

  Future<void> _leaveSquarle() async {
    final sessionId = widget.joinResult.sessionId;
    if (sessionId == null || sessionId.isEmpty || _isLeaving) return;

    setState(() => _isLeaving = true);

    try {
      await _squarleService.leaveSquarle(sessionId);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLeaving = false);
      _showNotice(error.toString(), SquarleNoticeTone.orange);
    }
  }

  List<SquarleTable> _visibleTables() {
    if (widget.joinResult.visibleTables.isNotEmpty) {
      return widget.joinResult.visibleTables;
    }

    final view = widget.joinResult.view ?? 1;
    final start = switch (view) {
      1 => 1,
      2 => 10,
      3 => 19,
      _ => 28,
    };
    final end = switch (view) {
      1 => 13,
      2 => 22,
      3 => 31,
      _ => 40,
    };

    return List.generate(end - start + 1, (index) {
      final tableNumber = start + index;
      return SquarleTable(
        id: 'fallback_$tableNumber',
        tableNumber: tableNumber,
        occupancy: tableNumber == widget.joinResult.tableNumber ? 1 : 0,
      );
    });
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
            Positioned.fill(
              child: SquarleTableField(
                tables: _visibleTables(),
                assignedTableNumber: widget.joinResult.tableNumber,
                px: px,
                py: py,
                onTableTap: _handleTableTap,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 28 * py,
              child: Center(
                child: SquarleBottomControls(
                  px: px,
                  py: py,
                  isLoading: _isLeaving,
                  onSlideOut: _leaveSquarle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
