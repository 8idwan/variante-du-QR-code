import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:variante_du_qr_code/qr_code_utils.dart';

class DecoderScreen extends StatefulWidget {
  const DecoderScreen({Key? key}) : super(key: key);

  @override
  State<DecoderScreen> createState() => _DecoderScreenState();
}

class _DecoderScreenState extends State<DecoderScreen> {
  File? imageFile;
  String decodedString = '';
  final ImagePicker _picker = ImagePicker(); // Instance of ImagePicker

  Future<void> pickImage(ImageSource source) async {
    // Use ImageSource.camera or ImageSource.gallery
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> decodeImage() async {
    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image first.')));
      return;
    }

    try {
      final image = img.decodeImage(await imageFile!.readAsBytes());
      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not decode image.')));
        return;
      }

      final decoded = decode(image); // Use your decode function
      setState(() {
        decodedString = decoded;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Decoding error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Decoder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute buttons evenly
              children: [
                ElevatedButton(
                  onPressed: () => pickImage(ImageSource.gallery),
                  child: const Text('Select from Gallery'),
                ),
                ElevatedButton(
                  onPressed: () => pickImage(ImageSource.camera), // Open Camera
                  child: const Text('Take a Picture'),
                ),
              ],
            ),
            if (imageFile != null)
              Expanded(
                child: Image.file(imageFile!),
              ),
            ElevatedButton(
              onPressed: decodeImage, // Fixed: removed underscore
              child: const Text('Decode Image'),
            ),
            if (decodedString.isNotEmpty)
              Text('Decoded String: $decodedString'),
          ],
        ),
      ),
    );
  }
}