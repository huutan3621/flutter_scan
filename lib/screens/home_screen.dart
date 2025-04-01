// import 'package:ai_barcode/ai_barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scanner_app/controller/home_provider.dart';
import 'package:flutter_scanner_app/model/product_model.dart';
import 'package:flutter_scanner_app/widgets/custom_button.dart';
import 'package:flutter_scanner_app/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

export 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

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
    await homeProvider.onRefresh(context);
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: 279,
      height: 279,
    );
    return Consumer<HomeProvider>(
      builder: (context, value, child) {
        return value.userName == "" || value.userName == null
            ? HomeScreenInput(value, context)
            : HomeScreenMain(value, context);
      },
    );
  }

  Widget HomeScreenInput(HomeProvider value, BuildContext context) {
    return CustomLoadingOverlay(
      isLoading: value.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nhập mã số nhân sự'),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              onTap: () {
                value.updateUserName();
              },
              title: 'Cập nhật',
              btnColor: Colors.green[300],
              margin: const EdgeInsets.all(16),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: value.userNameController,
                  decoration: const InputDecoration(
                    labelText: 'Mã nhân sự',
                    hintText: 'Mã nhân sự',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const Text(
                'Mã nhân sự bắt buộc phải là NSXXXX, trong đó XXXX là một dãy số',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget HomeScreenMain(HomeProvider value, BuildContext context) {
    return CustomLoadingOverlay(
      isLoading: value.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Danh sách'),
          actions: [
            Visibility(
              visible: value.locationController.text != "",
              child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshData,
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Visibility(
              //   visible:
              //       value.scanProduct != "" && value.locationData == "",
              //   child: CustomButton(
              //     onTap: () async {
              //       value.updateLocation(context);
              //     },
              //     title: 'Thêm vị trí',
              //     btnColor: Colors.purple[300],
              //   ),
              // ),
              CustomButton(
                onTap: () async {
                  value.updateTable(context);
                },
                title: 'Cập nhật',
                btnColor: Colors.green[300],
              ),
              const SizedBox(
                height: 16,
              ),
              CustomButton(
                onTap: () async {
                  value.cleanTable(context);
                },
                title: 'Tạo mới',
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.only(bottom: 16),
                    //   child: TextFormField(
                    //     controller: value.locationController,
                    //     keyboardType: TextInputType.none,
                    //     readOnly: true,
                    //     decoration: const InputDecoration(
                    //       labelText: 'Vị trí',
                    //       hintText: 'Vị trí',
                    //       border: OutlineInputBorder(),
                    //       suffixIcon: Icon(Icons.qr_code),
                    //     ),
                    //     onTap: () async {
                    //       value.locationToScanScreen(context);
                    //     },
                    //   ),
                    // ),
                    Text(
                      'Mã nhân sự: ${value.userName}',
                      style: const TextStyle(fontSize: 16),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 16, top: 16),
                      child: TextFormField(
                        controller: value.productController,
                        // enabled: value.locationController.text != "",
                        keyboardType: TextInputType.none,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Mã sản phẩm',
                          hintText: 'Mã sản phẩm',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.qr_code),
                        ),
                        onTap: () async {
                          value.productToScanScreen(context);
                        },
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(bottom: 16),
                    //   child: Text(
                    //     "Vị trí sản phẩm: ${value.locationData}",
                    //     style: const TextStyle(fontSize: 24),
                    //   ),
                    // ),
                    // SizedBox(
                    //     width: MediaQuery.of(context).size.width,
                    //     height: MediaQuery.of(context).size.width,
                    //     child: PlatformAiBarcodeScannerWidget(
                    //       platformScannerController:
                    //           value.creatorController,
                    //     )),
                    // value.isCameraGranted
                    //     ?
                    // SizedBox(
                    //   width: MediaQuery.of(context).size.width,
                    //   height: MediaQuery.of(context).size.width,
                    //   child: Stack(
                    //     children: [
                    //       MobileScanner(
                    //         controller: value.qrController,
                    //         fit: BoxFit.cover,
                    //         onDetect: (capture) {
                    //           value.onDetect(capture, context);
                    //         },
                    //         scanWindow: scanWindow,
                    //       ),
                    //       Container(
                    //         decoration: ShapeDecoration(
                    //           shape: CustomQrScannerOverlayShape(
                    //             borderColor:
                    //                 const Color.fromARGB(255, 6, 4, 4),
                    //             borderWidth: 8.0,
                    //             overlayColor:
                    //                 const Color.fromRGBO(0, 0, 0, 60),
                    //             borderRadius: 4,
                    //             borderLength: 40,
                    //             cutOutSize: 279,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // )
                    // : SizedBox(
                    //     width: MediaQuery.of(context).size.width,
                    //     height: MediaQuery.of(context).size.width,
                    //     child: Stack(
                    //       children: [
                    //         Container(
                    //           decoration: ShapeDecoration(
                    //             shape: CustomQrScannerOverlayShape(
                    //               borderColor: const Color.fromARGB(
                    //                   255, 6, 4, 4),
                    //               borderWidth: 8.0,
                    //               overlayColor:
                    //                   const Color.fromRGBO(0, 0, 0, 60),
                    //               borderRadius: 4,
                    //               borderLength: 40,
                    //               cutOutSize: 279,
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   )
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
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
                          child: const Text('Xoá',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      DataColumn(
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text('SKU',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      DataColumn(
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text('Tên sản phẩm',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      // DataColumn(
                      //   label: Container(
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: const Text('Barcode',
                      //         style: TextStyle(fontWeight: FontWeight.bold)),
                      //   ),
                      // ),
                      DataColumn(
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text('Đơn vị',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      DataColumn(
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text('Độ dài (mm)',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      DataColumn(
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text('Chiều rộng (mm)',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      DataColumn(
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text('Chiều cao (mm)',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      DataColumn(
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text('Cân nặng (mg)',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      DataColumn(
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text('Hình ảnh',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                    rows: value.dataList.isEmpty
                        ? [
                            DataRow(
                              cells: [
                                DataCell(
                                  Container(),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    child: const Center(
                                      child: Text("Không có dữ liệu",
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.red)),
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
                                    margin: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
                                        onTap: () {
                                          value.showAlertDialog(
                                              context,
                                              value.dataList[rowIndex]
                                                      .productId ??
                                                  0);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.red[400],
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                        )),
                                  )),
                                  DataCell(Container(
                                    child: Center(
                                        child: Text(value
                                            .dataList[rowIndex].itemCode
                                            .toString())),
                                  )),
                                  DataCell(Container(
                                    child: Center(
                                        child: Text(value
                                            .dataList[rowIndex].itemName
                                            .toString())),
                                  )),
                                  // DataCell(Container(
                                  //   child: Center(
                                  //       child: Text(
                                  //           value.dataList[rowIndex].barCode)),
                                  // )),
                                  DataCell(Container(
                                    child: Center(
                                        child: Text(value
                                            .dataList[rowIndex].unitOfMeasure
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
                                                : const SizedBox.shrink()),
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
  }
}
