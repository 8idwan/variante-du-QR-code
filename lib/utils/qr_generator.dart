import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Future<ui.Image> generateQRImage(String binaryData, {required int size}) async {
  const cellSize = 40.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint();

  // Dessiner les bordures alternées
  for (int i = 0; i < size; i++) {
    paint.color = i.isEven ? Colors.black : Colors.white;
    // Première ligne
    canvas.drawRect(
      Rect.fromLTWH(i * cellSize, 0, cellSize, cellSize),
      paint,
    );
    // Première colonne
    canvas.drawRect(
      Rect.fromLTWH(0, i * cellSize, cellSize, cellSize),
      paint,
    );
  }

  // Remplir la zone centrale
  final requiredBits = (size - 2) * (size - 2);
  final dataBits = binaryData.padRight(requiredBits, '0').substring(0, requiredBits);
  int bitIndex = 0;

  for (int y = 1; y < size - 1; y++) {
    for (int x = 1; x < size - 1; x++) {
      paint.color = dataBits[bitIndex] == '1' ? Colors.black : Colors.white;
      canvas.drawRect(
        Rect.fromLTWH(
          x * cellSize,
          y * cellSize,
          cellSize,
          cellSize,
        ),
        paint,
      );
      bitIndex++;
    }
  }

  final picture = recorder.endRecording();
  return await picture.toImage(
    (size * cellSize).toInt(),
    (size * cellSize).toInt(),
  );
}