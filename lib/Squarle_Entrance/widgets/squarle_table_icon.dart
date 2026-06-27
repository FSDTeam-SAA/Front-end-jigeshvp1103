import 'package:flutter/material.dart';

import '../models/squarle_table.dart';

class SquarleTableIcon extends StatelessWidget {
  final SquarleTable table;
  final bool isAssigned;
  final double px;
  final VoidCallback? onTap;

  const SquarleTableIcon({
    super.key,
    required this.table,
    required this.isAssigned,
    required this.px,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final asset = isAssigned
        ? 'assets/icons/table_open.png'
        : 'assets/icons/table_close.png';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 64 * px,
        height: 64 * px,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10 * px),
          boxShadow: isAssigned
              ? const [
                  BoxShadow(
                    color: Color(0x552B88CF),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Image.asset(asset, fit: BoxFit.contain),
      ),
    );
  }
}
