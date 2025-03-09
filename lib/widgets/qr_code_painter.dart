import 'package:flutter/material.dart';

class QrCodePainter extends CustomPainter {
  final List<List<bool>> grid;
  final Color blackColor;
  final Color whiteColor;

  QrCodePainter({
    required this.grid,
    required this.blackColor,
    required this.whiteColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / grid.length;
    final paint = Paint();

    for (var y = 0; y < grid.length; y++) {
      for (var x = 0; x < grid[y].length; x++) {
        paint.color = grid[y][x] ? blackColor : whiteColor;
        canvas.drawRect(
          Rect.fromLTWH(
            x * cellSize,
            y * cellSize,
            cellSize,
            cellSize,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(QrCodePainter oldDelegate) =>
      grid != oldDelegate.grid ||
          blackColor != oldDelegate.blackColor ||
          whiteColor != oldDelegate.whiteColor;
}