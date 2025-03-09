import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/qr_code_utils.dart';

class DecoderScreen extends StatefulWidget {
  const DecoderScreen({super.key});

  @override
  State<DecoderScreen> createState() => _DecoderScreenState();
}

class _DecoderScreenState extends State<DecoderScreen> {
  File? _image;
  String _result = '';

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _result = 'Analyse en cours...';
    });

    try {
      final decoded = decodeImage(_image!);
      setState(() => _result = 'Résultat: $decoded');
    } catch (e) {
      setState(() => _result = 'Erreur: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Décodeur')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Importer image')),
            const SizedBox(height: 20),
            if (_image != null)
              Expanded(
                child: Image.file(_image!),
              ),
            const SizedBox(height: 20),
            Text(_result, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}