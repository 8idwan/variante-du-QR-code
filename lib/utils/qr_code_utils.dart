import 'dart:io';

import 'package:image/image.dart' as img;

List<List<bool>> encode(String binaryString, int size) {
  final requiredBits = (size - 2) * (size - 2);
  if (binaryString.length != requiredBits ||
      !RegExp(r'^[01]+$').hasMatch(binaryString)) {
    throw ArgumentError('Doit contenir $requiredBits bits (0/1)');
  }

  final grid = List.generate(size, (i) => List.filled(size, false));

  // Bordures alternées
  for (var i = 0; i < size; i++) {
    grid[0][i] = i.isEven;
    grid[i][0] = i.isEven;
  }

  // Remplissage central
  var index = 0;
  for (var y = 1; y < size - 1; y++) {
    for (var x = 1; x < size - 1; x++) {
      grid[y][x] = binaryString[index] == '1';
      index++;
    }
  }

  return grid;
}

String decodeImage(File imageFile) {
  // Décoder l'image
  final image = img.decodeImage(imageFile.readAsBytesSync())!;

  // Convertir en niveaux de gris
  final grayImage = img.grayscale(image);

  // Redimensionner l'image
  final resizedImage = img.copyResize(
    grayImage,
    width: 500,
    height: 500,
    interpolation: img.Interpolation.cubic,
  );

  // Détecter la taille du QR code
  final size = _detectSize(resizedImage);

  // Extraire les données
  var result = '';
  final cellSize = resizedImage.width ~/ size;

  for (int y = 1; y < size - 1; y++) {
    for (int x = 1; x < size - 1; x++) {
      final pixel = resizedImage.getPixel(
        x * cellSize + cellSize ~/ 2,
        y * cellSize + cellSize ~/ 2,
      );
      result += img.getLuminance(pixel) < 128 ? '1' : '0';
    }
  }

  return result;
}

int _detectSize(img.Image image) {
  final possibleSizes = [5, 7];
  final cellSizeThreshold = 20; // Ajuster selon la résolution

  for (final size in possibleSizes) {
    bool isValid = true;
    final expectedPattern = List.generate(size, (i) => i.isEven);

    // Vérifier la première ligne
    for (int i = 0; i < size; i++) {
      final x = (i * image.width / size).round();
      final pixel = image.getPixel(x, 0);
      final isBlack = img.getLuminance(pixel) < 128;
      if (isBlack != expectedPattern[i]) {
        isValid = false;
        break;
      }
    }

    if (isValid) return size;
  }

  throw Exception('Format non supporté : Utilisez 5x5 ou 7x7');
}