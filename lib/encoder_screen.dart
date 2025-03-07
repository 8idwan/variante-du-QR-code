import 'package:flutter/material.dart';
import 'package:variante_du_qr_code/qr_code_painter.dart';
import 'package:variante_du_qr_code/qr_code_utils.dart';

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
                  setState(() {}); // Trigger UI update
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text('Generate QR Code'),
            ),
            if (qrCodeData != null)
              Expanded(
                child: Center(
                  child: CustomPaint(
                    size: const Size(300, 300),
                    painter: QrCodePainter(grid: qrCodeData!, blackColor: Colors.black, whiteColor: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}