import 'package:flutter/material.dart';

class QrCodePainter extends CustomPainter {
  final List<List<bool>> grid;
  final Color blackColor;
  final Color whiteColor;

  QrCodePainter({required this.grid, required this.blackColor, required this.whiteColor});

  @override
  void paint(Canvas canvas, Size size) {
    double blockSize = size.width / grid.length;

    for (int row = 0; row < grid.length; row++) {
      for (int col = 0; col < grid[row].length; col++) {
        final paint = Paint()
          ..color = grid[row][col] ? blackColor : whiteColor
          ..style = PaintingStyle.fill;

        final rect = Rect.fromLTWH(col * blockSize, row * blockSize, blockSize, blockSize);
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(QrCodePainter oldDelegate) {
    return grid != oldDelegate.grid || blackColor != oldDelegate.blackColor || whiteColor != oldDelegate.whiteColor;
  }
}