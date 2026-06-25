import 'package:flutter/material.dart';

import '../controller/canvas_controller.dart';
import '../model/drawing_stroke.dart';

class CanvasView extends StatelessWidget {
  const CanvasView({
    super.key,
    required this.controller,
    this.backgroundColor = Colors.white,
  });

  final CanvasController controller;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final isActiveErasing =
              controller.currentStroke?.mode == StrokeMode.erase;

          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (!isActiveErasing)
                RepaintBoundary(
                  child: CustomPaint(
                    painter: _CompletedStrokesPainter(
                      controller: controller,
                      repaint: controller.completedPaintListenable,
                    ),
                  ),
                ),
              CustomPaint(
                painter: _ActiveStrokePainter(
                  controller: controller,
                  repaint: controller.activePaintListenable,
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (details) {
                    controller.startStroke(
                      point: _localPoint(context, details.globalPosition),
                      color: controller.selectedColor,
                      strokeWidth: controller.selectedStrokeWidth,
                      mode: controller.selectedMode,
                    );
                  },
                  onPanUpdate: (details) {
                    controller.updateStroke(
                      _localPoint(context, details.globalPosition),
                    );
                  },
                  onPanEnd: (_) => controller.endStroke(),
                  onPanCancel: controller.cancelCurrentStroke,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Offset _localPoint(BuildContext context, Offset globalPosition) {
    final box = context.findRenderObject() as RenderBox;
    return box.globalToLocal(globalPosition);
  }
}

class _CompletedStrokesPainter extends CustomPainter {
  _CompletedStrokesPainter({
    required this.controller,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final CanvasController controller;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    for (final stroke in controller.completedStrokes) {
      canvas.drawPath(stroke.path, stroke.paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CompletedStrokesPainter oldDelegate) {
    return oldDelegate.controller != controller;
  }
}

class _ActiveStrokePainter extends CustomPainter {
  _ActiveStrokePainter({required this.controller, required Listenable repaint})
    : super(repaint: repaint);

  final CanvasController controller;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = controller.currentStroke;
    if (stroke == null) {
      return;
    }

    if (stroke.mode == StrokeMode.erase) {
      canvas.saveLayer(Offset.zero & size, Paint());
      for (final completedStroke in controller.completedStrokes) {
        canvas.drawPath(completedStroke.path, completedStroke.paint);
      }
      canvas.drawPath(stroke.path, stroke.paint);
      canvas.restore();
      return;
    }

    canvas.drawPath(stroke.path, stroke.paint);
  }

  @override
  bool shouldRepaint(covariant _ActiveStrokePainter oldDelegate) {
    return oldDelegate.controller != controller;
  }
}
