import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('QR Code Scanner'),
        ),
        body: const QRCodeScanner(),
      ),
    );
  }
}

class QRCodeScanner extends StatefulWidget {
  const QRCodeScanner({super.key});

  @override
  _QRCodeScannerState createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  String result = '';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(result),
          ElevatedButton(
            onPressed: () async {
              var res = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SimpleBarcodeScannerPage(),
                ),
              );
              setState(() {
                if (res is String) {
                  if (_isValidQRCode(res)) {
                    result = res;
                  } else {
                    result = 'Mã không hợp lệ';
                  }
                }
              });
            },
            child: const Text('Scan QR Code'),
          ),
        ],
      ),
    );
  }

  bool _isValidQRCode(String code) {
    final qrCodeRegex = RegExp(r'^9\d{5}$');
    final barcodeRegex =
        RegExp(r'^\d{12,13}$'); // Giả sử mã vạch sản phẩm có 12 hoặc 13 chữ số
    return qrCodeRegex.hasMatch(code) || barcodeRegex.hasMatch(code);
  }
}

void main() => runApp(const MyApp());
