import 'package:image/image.dart' as img;

List<List<bool>> encode(String binaryString, int size) {
  if (binaryString.length > (size - 2) * (size - 2)) {
    throw ArgumentError('Binary string is too long for the given QR code size.');
  }

  List<List<bool>> grid = List.generate(size, (i) => List.generate(size, (j) => false));

  for (int i = 0; i < size; i++) {
    grid[0][i] = (i % 2 == 0);
    grid[i][0] = (i % 2 == 0);
  }

  int dataIndex = 0;
  for (int row = 1; row < size - 1; row++) {
    for (int col = 1; col < size - 1; col++) {
      if (dataIndex < binaryString.length) {
        grid[row][col] = (binaryString[dataIndex] == '1');
        dataIndex++;
      }
    }
  }

  return grid;
}

String decode(img.Image image) {
  // 1. Binarization (Thresholding)
  List<List<bool>> binarizedImage = _binarizeImage(image);

  // 2. Size Detection
  int size = _detectSize(binarizedImage);

  if (size < 5) {
    return "Could not detect QR code size.  Image may be too small or invalid.";
  }

  // 3. Data Extraction
  String decodedString = _extractData(binarizedImage, size);

  return decodedString;
}


List<List<bool>> _binarizeImage(img.Image image) {
  List<List<bool>> binarizedImage = List.generate(
      image.height, (i) => List.generate(image.width, (j) => false));

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);

      // Extract color channels directly from the pixel value
      final r = pixel.r;
      final g = pixel.g;
      final b = pixel.b;

      // Simple grayscale conversion
      int grayscale = ((r * 0.299) + (g * 0.587) + (b * 0.114)).round();

      // Thresholding (you might need to adjust the threshold)
      binarizedImage[y][x] = grayscale < 128; // true for black, false for white
    }
  }

  return binarizedImage;
}

int _detectSize(List<List<bool>> binarizedImage) {
  int height = binarizedImage.length;
  int width = binarizedImage[0].length;

  // Check if the image is too small
  if (height < 5 || width < 5) {
    return 0; // Invalid size
  }

  // Assume the top-left corner has the alternating pattern
  int size = 0;
  for (int i = 5; i <= 7 && i <= height && i <= width; i++) {
    bool validSize = true;

    // Check the first row and first column for the alternating pattern.  This checks
    // the first *i* elements.
    for (int j = 0; j < i; j++) {
      if (binarizedImage[0][j] != (j % 2 == 0)) {
        validSize = false;
        break;
      }
      if (binarizedImage[j][0] != (j % 2 == 0)) {
        validSize = false;
        break;
      }
    }

    if (validSize) {
      size = i;
    }
  }

  return size;
}

String _extractData(List<List<bool>> binarizedImage, int size) {
  String decodedString = "";

  for (int row = 1; row < size - 1; row++) {
    for (int col = 1; col < size - 1; col++) {
      decodedString += (binarizedImage[row][col] ? '1' : '0');
    }
  }

  return decodedString;
}