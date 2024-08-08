import 'package:flutter/material.dart';
import 'package:flutter_scanner_app/screens/create_item_screen.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _scanResult = '';
  final TextEditingController _textController = TextEditingController();
  void _handleScanResult(String result) {
    if (_isValidQRCode(result) || _isValidBarcode(result)) {
      setState(() {
        _scanResult = result;
        _textController.text = _scanResult;
      });
    } else if (_isValidTextFormat(result)) {
      setState(() {
        _scanResult = _extractNumberFromText(result);
        _textController.text = _scanResult;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã quét không hợp lệ.')),
      );
    }
  }

  bool _isValidQRCode(String code) {
    final regex = RegExp(r'^9\d{5}$');
    return regex.hasMatch(code);
  }

  bool _isValidBarcode(String code) {
    final regex = RegExp(r'^\d{13}$');
    return regex.hasMatch(code);
  }

  bool _isValidTextFormat(String text) {
    final regex = RegExp(r'^9\d{5};');
    return regex.hasMatch(text);
  }

  String _extractNumberFromText(String text) {
    final match = RegExp(r'^9\d{5}').firstMatch(text);
    return match?.group(0) ?? '';
  }

  List<List<String>> data = [
    List.generate(8, (index) => 'Header $index'),
    List.generate(8, (index) => 'Data $index'),
  ];

  void _addRow() {
    setState(() {
      data.add(List.generate(8, (index) => 'New Data $index'));
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item List'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            //btn field
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        var res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SimpleBarcodeScannerPage(),
                          ),
                        );
                        if (res is String) {
                          _handleScanResult(res);
                        }
                      },
                      child: TextField(
                        enabled: false,
                        controller: _textController, //display result here
                        decoration: const InputDecoration(
                          hintText: 'Scan item...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateItemPage(),
                        ),
                      );
                    },
                    child: const Text('Create'),
                  ),
                ],
              ),
            ),
            // Table Header and Content
            Container(
              color: Colors.orange,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    // Header Row
                    Table(
                      border: TableBorder.all(color: Colors.black),
                      columnWidths: const {
                        0: FixedColumnWidth(100),
                        1: FixedColumnWidth(100),
                        2: FixedColumnWidth(100),
                        3: FixedColumnWidth(100),
                        4: FixedColumnWidth(100),
                        5: FixedColumnWidth(100),
                        6: FixedColumnWidth(100),
                        7: FixedColumnWidth(100),
                      },
                      children: [
                        TableRow(
                          children: List.generate(
                              8, (index) => _buildHeaderCell('Header $index')),
                        ),
                      ],
                    ),
                    // Data Rows
                    Container(
                      color: Colors.white,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Table(
                          border: TableBorder.all(color: Colors.black),
                          columnWidths: const {
                            0: FixedColumnWidth(100),
                            1: FixedColumnWidth(100),
                            2: FixedColumnWidth(100),
                            3: FixedColumnWidth(100),
                            4: FixedColumnWidth(100),
                            5: FixedColumnWidth(100),
                            6: FixedColumnWidth(100),
                            7: FixedColumnWidth(100),
                          },
                          children: List.generate(data.length, (rowIndex) {
                            return TableRow(
                              children: List.generate(8, (colIndex) {
                                return _buildDataCell(data[rowIndex][colIndex]);
                              }),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _addRow,
              child: const Text('Thêm hàng'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
