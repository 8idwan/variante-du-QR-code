import 'package:flutter/material.dart';
import '../utils/qr_code_utils.dart';
import '../widgets/qr_code_painter.dart';

class EncoderScreen extends StatefulWidget {
  const EncoderScreen({Key? key}) : super(key: key);

  @override
  State<EncoderScreen> createState() => _EncoderScreenState();
}

class _EncoderScreenState extends State<EncoderScreen> {
  String binaryString = '';
  int qrCodeSize = 5;
  List<List<bool>>? qrCodeData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encodeur QR Code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Suite binaire (0 et 1)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => binaryString = value),
            ),
            const SizedBox(height: 20),
            DropdownButton<int>(
              value: qrCodeSize,
              items: [5, 7].map((size) => DropdownMenuItem(
                value: size,
                child: Text('$size x $size'),
              )).toList(),
              onChanged: (value) => setState(() => qrCodeSize = value!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                try {
                  setState(() {
                    qrCodeData = encode(binaryString, qrCodeSize);
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text('Générer QR Code'),
            ),
            const SizedBox(height: 20),
            if (qrCodeData != null)
              Expanded(
                child: Center(
                  child: CustomPaint(
                    size: const Size(300, 300),
                    painter: QrCodePainter(
                      grid: qrCodeData!,
                      blackColor: Colors.black,
                      whiteColor: Colors.white,
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