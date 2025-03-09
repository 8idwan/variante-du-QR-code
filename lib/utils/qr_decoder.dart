import 'dart:io';
import 'package:image/image.dart' as img;

Future<String?> decodeQRImage(String imagePath) async {
  final image = img.decodeImage(await File(imagePath).readAsBytes())!;
  final grayImage = img.grayscale(image);

  // Calcul du seuil
  double total = 0;
  for (int y = 0; y < grayImage.height; y++) {
    for (int x = 0; x < grayImage.width; x++) {
      total += img.getLuminance(grayImage.getPixel(x, y));
    }
  }
  final threshold = (total / (grayImage.width * grayImage.height)).toInt();

  // Binarisation
  final binaryImage = img.copyResize(grayImage, width: 500);
  for (int y = 0; y < binaryImage.height; y++) {
    for (int x = 0; x < binaryImage.width; x++) {
      final luminance = img.getLuminance(binaryImage.getPixel(x, y));
      binaryImage.setPixelRgba(
          x,
          y,
          luminance < threshold ? 0 : 255,
          luminance < threshold ? 0 : 255,
          luminance < threshold ? 0 : 255,
          255
      );
    }
  }

  // Détection de la taille
  final size = _detectQRSize(binaryImage);
  return size != null ? _extractCentralData(binaryImage, size) : null;
}

int? _detectQRSize(img.Image image) {
  const cellSize = 500 ~/ 7;
  final pattern = List.generate(7, (i) => i.isEven);

  for (final size in [5, 7]) {
    bool valid = true;
    for (int i = 0; i < size; i++) {
      final pixel = image.getPixel(i * cellSize + cellSize ~/ 2, cellSize ~/ 2);
      if (img.getLuminance(pixel) < 128 != pattern[i]) {
        valid = false;
        break;
      }
    }
    if (valid) return size;
  }
  return null;
}

String _extractCentralData(img.Image image, int size) {
  const cellSize = 500 ~/ 7;
  final buffer = StringBuffer();

  for (int y = 1; y < size - 1; y++) {
    for (int x = 1; x < size - 1; x++) {
      final pixel = image.getPixel(
        x * cellSize + cellSize ~/ 2,
        y * cellSize + cellSize ~/ 2,
      );
      buffer.write(img.getLuminance(pixel) < 128 ? '1' : '0');
    }
  }
  return buffer.toString();
}