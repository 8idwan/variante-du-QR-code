import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:image_gallery_saver/image_gallery_saver.dart'; // Import the package
import 'package:permission_handler/permission_handler.dart';
import 'package:variante_du_qr_code/qr_code_painter.dart';
import 'package:variante_du_qr_code/qr_code_utils.dart'; // Import permission handler

class EncoderScreen extends StatefulWidget {
  const EncoderScreen({Key? key}) : super(key: key);

  @override
  State<EncoderScreen> createState() => _EncoderScreenState();
}

class _EncoderScreenState extends State<EncoderScreen> {
  String binaryString = '';
  int qrCodeSize = 5;
  List<List<bool>>? qrCodeData;
  GlobalKey _qrCodeKey = GlobalKey(); // Key for RepaintBoundary

  void _loadTestData() {
    setState(() {
      binaryString = '101010101';
      qrCodeSize = 5;
    });
  }

  // ********** NEW METHOD TO SAVE IMAGE **********
  Future<void> _saveImage() async {
    try {
      // 1. Check and request permission
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission denied to save image.')));
          return; // Stop if permission is not granted
        }
      }

      // 2. Capture the widget as an image
      RenderRepaintBoundary boundary = _qrCodeKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0); // Increased pixel ratio for better quality
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();

        // 3. Save the image to the gallery
        final result = await ImageGallerySaver.saveImage(
          pngBytes,
          quality: 90,  // Adjust quality as needed (0-100)
          name: "qr_code_${DateTime.now().millisecondsSinceEpoch}", // Unique filename
        );

        if (result != null && result is String) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image saved to gallery!')));
          print('Image saved to gallery!'); // Debug
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save image. Check permissions.')));
          print('Failed to save image.'); // Debug
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not get byte data.')));
      }
    } catch (e, stackTrace) {
      print('Error saving image: $e');
      print('Stack trace: $stackTrace');
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving image: $e')));
    }
  }
  // ********** END NEW METHOD **********

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Encoder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Binary String (0s and 1s)'),
              onChanged: (value) {
                setState(() {
                  binaryString = value;
                });
              },
              controller: TextEditingController(text: binaryString),
            ),
            DropdownButton<int>(
              value: qrCodeSize,
              items: [5, 7].map((size) => DropdownMenuItem(
                value: size,
                child: Text('$size x $size'),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  qrCodeSize = value!;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                try {
                  qrCodeData = encode(binaryString, qrCodeSize);
                  setState(() {});
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text('Generate QR Code'),
            ),
            ElevatedButton(
              onPressed: _loadTestData,
              child: const Text('Load Test Data'),
            ),
            // ********** SAVE IMAGE BUTTON **********
            ElevatedButton(
              onPressed: _saveImage,
              child: const Text('Save Image to Gallery'),
            ),
            // ********** END SAVE IMAGE BUTTON **********
            if (qrCodeData != null)
              Expanded(
                child: Center(
                  child: RepaintBoundary(
                    key: _qrCodeKey,
                    child: Container(
                      width: 300,
                      height: 300,
                      color: Colors.white, // Ensure a white background
                      child: CustomPaint(
                        size: const Size(300, 300),
                        painter: QrCodePainter(grid: qrCodeData!, blackColor: Colors.black, whiteColor: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}