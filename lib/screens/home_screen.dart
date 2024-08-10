import 'package:flutter/material.dart';
import 'package:flutter_scanner_app/controller/home_provider.dart';
import 'package:flutter_scanner_app/model/product_model.dart';
import 'package:provider/provider.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeProvider(),
      child: const HomeChild(),
    );
  }
}

class HomeChild extends StatefulWidget {
  const HomeChild({super.key});

  @override
  State<HomeChild> createState() => _HomeChildState();
}

class _HomeChildState extends State<HomeChild> {
  // Initialize the provider
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var homeProvider = Provider.of<HomeProvider>(context, listen: false);
      homeProvider.init(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    var homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Item List'),
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                // Button field
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
                              value.handleScanResult(res, context);
                            }
                          },
                          child: TextField(
                            enabled: false,
                            controller:
                                value.textController, // Display result here
                            decoration: const InputDecoration(
                                hintText: 'Scan item...',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.qr_code)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          value.navigateToCreateScreen(context);
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
                            7: FixedColumnWidth(150),
                          },
                          children: [
                            TableRow(
                              children: [
                                _buildHeaderCell('Item Code'),
                                _buildHeaderCell('Bar Code'),
                                _buildHeaderCell('Unit'),
                                _buildHeaderCell('Length'),
                                _buildHeaderCell('Width'),
                                _buildHeaderCell('Height'),
                                _buildHeaderCell('Weight'),
                                _buildHeaderCell('Image'),
                              ],
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
                                7: FixedColumnWidth(150),
                              },
                              children: List.generate(value.dataList.length,
                                  (rowIndex) {
                                final List<ImageViewModel> images =
                                    value.dataList[rowIndex].images ?? [];

                                final hasMoreImages = images.length > 1;

                                return TableRow(children: [
                                  _buildDataCell(value
                                      .dataList[rowIndex].itemCode
                                      .toString()),
                                  _buildDataCell(
                                      value.dataList[rowIndex].barCode),
                                  _buildDataCell(value
                                      .dataList[rowIndex].unitOfMeasure
                                      .toString()),
                                  _buildDataCell(value.dataList[rowIndex].length
                                      .toString()),
                                  _buildDataCell(value.dataList[rowIndex].width
                                      .toString()),
                                  _buildDataCell(value.dataList[rowIndex].height
                                      .toString()),
                                  _buildDataCell(value.dataList[rowIndex].weight
                                      .toString()),
                                  GestureDetector(
                                    onTap: () {
                                      if (images.isNotEmpty) {
                                        value.showImagePreviewDialog(
                                            context, images);
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        if (images.isNotEmpty)
                                          Flexible(
                                            child: AspectRatio(
                                              aspectRatio: 1,
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    images[0].url ?? "",
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (hasMoreImages)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Text(
                                              '+${images.length - 1} more',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ]);
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
    return GestureDetector(
      onTap: null, // No action for text cells
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
