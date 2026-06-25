import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../controller/canvas_controller.dart';
import '../model/drawing_stroke.dart';

class ToolbarControls extends StatelessWidget {
  const ToolbarControls({
    super.key,
    required this.controller,
    required this.isExporting,
    required this.onSend,
    required this.onPenTap,
    required this.onEraserTap,
  });

  final CanvasController controller;
  final bool isExporting;
  final VoidCallback onSend;
  final VoidCallback onPenTap;
  final VoidCallback onEraserTap;

  @override
  Widget build(BuildContext context) {
    final isEraser = controller.selectedMode == StrokeMode.erase;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            _CircleSvgButton(
              assetPath: 'assets/icons/undo.svg',
              backgroundColor: Colors.white,
              iconColor: const Color(0xFF202020),
              disabledIconColor: const Color(0xFF808080),
              onPressed: controller.canUndo ? controller.undo : null,
            ),
            const SizedBox(width: 8),
            _ToolbarSvgButton(
              assetPath: 'assets/icons/redo.svg',
              iconColor: const Color(0xFF202020),
              disabledIconColor: const Color(0xFF808080),
              selected: controller.canRedo,
              onPressed: controller.canRedo ? controller.redo : null,
            ),
          ],
        ),
        Row(
          children: <Widget>[
            _ToolbarSvgButton(
              assetPath: 'assets/icons/pen.svg',
              iconColor: const Color(0xFF202020),
              disabledIconColor: const Color(0xFF808080),
              selected: !isEraser,
              onPressed: () {
                controller.setStrokeMode(StrokeMode.draw);
                onPenTap();
              },
            ),
            const SizedBox(width: 18),
            _ToolbarSvgButton(
              assetPath: 'assets/icons/ereaser.svg',
              iconColor: const Color(0xFF202020),
              disabledIconColor: const Color(0xFF808080),
              selected: isEraser,
              onPressed: () {
                controller.setStrokeMode(StrokeMode.erase);
                onEraserTap();
              },
            ),
          ],
        ),
        _SendDrawingButton(
          enabled: controller.hasCompletedStrokes && !isExporting,
          isLoading: isExporting,
          onPressed: onSend,
        ),
      ],
    );
  }
}

class _ToolbarSvgButton extends StatelessWidget {
  const _ToolbarSvgButton({
    required this.assetPath,
    required this.selected,
    required this.iconColor,
    required this.disabledIconColor,
    required this.onPressed,
  });

  final String assetPath;
  final bool selected;
  final Color iconColor;
  final Color disabledIconColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: SvgPicture.asset(
        assetPath,
        width: 28,
        height: 28,
        colorFilter: ColorFilter.mode(
          onPressed == null ? disabledIconColor : iconColor,
          BlendMode.srcIn,
        ),
      ),
      style: IconButton.styleFrom(
        fixedSize: const Size.square(46),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class _SendDrawingButton extends StatelessWidget {
  const _SendDrawingButton({
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
  });

  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled ? onPressed : null,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : SvgPicture.asset(
              enabled ? 'assets/icons/send.svg' : 'assets/icons/send_faded.svg',
              width: 48,
              height: 48,
            ),
      style: IconButton.styleFrom(
        fixedSize: const Size.square(48),
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        disabledBackgroundColor: Colors.transparent,
      ),
    );
  }
}

class _CircleSvgButton extends StatelessWidget {
  const _CircleSvgButton({
    required this.assetPath,
    required this.backgroundColor,
    required this.iconColor,
    required this.disabledIconColor,
    required this.onPressed,
  });

  final String assetPath;
  final Color backgroundColor;
  final Color iconColor;
  final Color disabledIconColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: SvgPicture.asset(
        assetPath,
        width: 25,
        height: 25,
        colorFilter: ColorFilter.mode(
          onPressed == null ? disabledIconColor : iconColor,
          BlendMode.srcIn,
        ),
      ),
      style: IconButton.styleFrom(
        fixedSize: const Size.square(48),
        backgroundColor: backgroundColor,
        disabledBackgroundColor: backgroundColor,
      ),
    );
  }
}

class DrawingCircleIconButton extends StatelessWidget {
  const DrawingCircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: const Color(0xFF202020),
      disabledColor: const Color(0xFFB8B8B8),
      style: IconButton.styleFrom(
        fixedSize: const Size.square(48),
        backgroundColor: const Color(0xFFF2F2F2),
        disabledBackgroundColor: const Color(0xFFF7F7F7),
      ),
    );
  }
}
