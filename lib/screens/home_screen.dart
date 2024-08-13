import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_scanner_app/controller/home_provider.dart';
import 'package:flutter_scanner_app/model/product_model.dart';
import 'package:flutter_scanner_app/widgets/custom_button.dart';
import 'package:flutter_scanner_app/widgets/loading_overlay.dart';
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

  void _refreshData() async {
    var homeProvider = Provider.of<HomeProvider>(context, listen: false);
    await homeProvider.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, value, child) {
        return CustomLoadingOverlay(
          isLoading: value.isLoading,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Item List'),
              actions: [
                Visibility(
                  visible: value.textController.text != "",
                  child: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _refreshData,
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: value.textController,
                            keyboardType: TextInputType.none,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'SKU',
                              hintText: 'SKU',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.qr_code),
                            ),
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
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 12,
                        dataRowHeight: 100,
                        border: TableBorder.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        columns: [
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: const Text('Item Code',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: const Text('Bar Code',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: const Text('Unit',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: const Text('Length (mm)',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: const Text('Width (mm)',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: const Text('Height (mm)',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: const Text('Weight (mg)',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: const Text('Image',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                        rows: value.dataList.isEmpty
                            ? [
                                DataRow(
                                  cells: [
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        child: const Center(
                                          child: Text("No data available",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.red)),
                                        ),
                                      ),
                                    ),
                                    ...List.generate(
                                      7,
                                      (index) => DataCell(Container()),
                                    ),
                                  ],
                                ),
                              ]
                            : List.generate(
                                value.dataList.length,
                                (rowIndex) {
                                  final List<ImageViewModel> images =
                                      value.dataList[rowIndex].images ?? [];
                                  final hasMoreImages = images.length > 1;

                                  return DataRow(
                                    cells: [
                                      DataCell(Container(
                                        child: Center(
                                            child: Text(value
                                                .dataList[rowIndex].itemCode
                                                .toString())),
                                      )),
                                      DataCell(Container(
                                        child: Center(
                                            child: Text(value
                                                .dataList[rowIndex].barCode)),
                                      )),
                                      DataCell(Container(
                                        child: Center(
                                            child: Text(value.dataList[rowIndex]
                                                .unitOfMeasure
                                                .toString())),
                                      )),
                                      DataCell(Container(
                                        child: Center(
                                            child: Text(value
                                                .dataList[rowIndex].length
                                                .toString())),
                                      )),
                                      DataCell(Container(
                                        child: Center(
                                            child: Text(value
                                                .dataList[rowIndex].width
                                                .toString())),
                                      )),
                                      DataCell(Container(
                                        child: Center(
                                            child: Text(value
                                                .dataList[rowIndex].height
                                                .toString())),
                                      )),
                                      DataCell(Container(
                                        child: Center(
                                            child: Text(value
                                                .dataList[rowIndex].weight
                                                .toString())),
                                      )),
                                      DataCell(Container(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (images.isNotEmpty) {
                                              value.showImagePreview(
                                                  context, images);
                                            }
                                          },
                                          child: Container(
                                            width: 100,
                                            height: 80,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: images.isNotEmpty
                                                  ? Image.network(
                                                      images[0].url ?? "",
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Container(
                                                      color: Colors.grey[200],
                                                    ),
                                            ),
                                          ),
                                        ),
                                      )),
                                    ],
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
