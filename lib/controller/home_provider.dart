import 'package:flutter/material.dart';
import 'package:flutter_scanner_app/model/product_model.dart';
import 'package:flutter_scanner_app/screens/create_item_screen.dart';
import 'package:flutter_scanner_app/service/api_service.dart';
import 'package:flutter_scanner_app/utils/network_helper.dart';
import 'package:flutter_scanner_app/utils/utils.dart';
import 'package:flutter_scanner_app/widgets/custom_button.dart';
import 'package:flutter_scanner_app/widgets/dialog_helper.dart';
import 'package:flutter_scanner_app/widgets/image_review_dialog.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class HomeProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();
  final NetworkHelper networkHelper = NetworkHelper();
  late String scanResult = '';
  final TextEditingController textController = TextEditingController();
  late List<ProductModel> dataList = [];
  late List<String> unitList = [];
  bool isLoading = false;
  bool _networkDialogShown = false;

  Future<void> init(BuildContext context) async {}

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> onRefresh(BuildContext context) async {
    dataList.clear();
    unitList.clear();
    await _fetchData(scanResult, context);
  }

  Future<void> navigateToScanScreen(BuildContext context) async {
    bool isConnected = await networkHelper.isConnected();
    debugPrint('Network connected: $isConnected');

    if (isConnected) {
      var res = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SimpleBarcodeScannerPage(),
        ),
      );
      if (res is String) {
        handleScanResult(res, context);
      }
    } else {
      debugPrint('No network connection. Showing error dialog.');
      DialogHelper.showErrorDialog(
        message: "Không có kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.",
      );
    }
  }

  Future<void> handleScanResult(String result, BuildContext context) async {
    scanResult = Utils.handleTSScanResult(result, context);
    textController.text = scanResult;
    notifyListeners();
    if (scanResult.isNotEmpty) {
      await _fetchData(scanResult, context);
    } else {
      dataList.clear();
      unitList.clear();
      notifyListeners();
    }
    await checkNavigateAfterScan(context);
  }

  Future<void> _fetchData(String itemNumber, BuildContext context) async {
    if (await networkHelper.isConnected()) {
      _networkDialogShown = false;
      setLoading(true);
      try {
        await Future.wait([
          apiService
              .getProductsById(itemNumber)
              .then((data) => dataList = data),
          apiService.getUnitById(itemNumber).then((units) => unitList = units),
        ]);
        notifyListeners();
      } catch (e) {
        // Handle exception if needed
      } finally {
        setLoading(false);
      }
    } else if (!_networkDialogShown) {
      _networkDialogShown = true;
      DialogHelper.showErrorDialog(message: "Không có kết nối mạng");
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  bool containsAllUnits() {
    final unitsInList = dataList.map((item) => item.unitOfMeasure).toSet();
    final allUnits = unitList.toSet();
    return allUnits.difference(unitsInList).isEmpty;
  }

  List<String> getMissingUnits() {
    final unitsInList = dataList.map((item) => item.unitOfMeasure).toSet();
    final allUnits = unitList.toSet();
    return allUnits.difference(unitsInList).toList();
  }

  List<String> getSelectedUnits() {
    final unitsInList = dataList.map((item) => item.unitOfMeasure).toSet();
    final allUnits = unitList.toSet();
    return unitsInList.intersection(allUnits).toList();
  }

  Future<void> cleanTable(BuildContext context) async {
    bool isConnected = await networkHelper.isConnected();
    debugPrint('Network connected: $isConnected');

    if (isConnected) {
      scanResult = "";
      textController.clear();
      dataList.clear();
      unitList.clear();
      notifyListeners();
      await navigateToCreateScreen(context);
    } else {
      debugPrint('No network connection. Showing error dialog.');
      DialogHelper.showErrorDialog(
        message: "Không có kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.",
      );
    }
  }

  Future<void> updateTable(BuildContext context) async {
    bool isConnected = await networkHelper.isConnected();
    debugPrint('Network connected: $isConnected');

    if (scanResult.isNotEmpty) {
      if (isConnected) {
        if (dataList.isNotEmpty) {
          await checkNavigate(context);
        } else {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateItemScreen(
                itemCode: scanResult,
                product: ProductModel(
                  itemCode: scanResult,
                  barCode: '',
                  unitOfMeasure: unitList.first,
                  length: 0,
                  width: 0,
                  height: 0,
                  weight: 0,
                  createBy: '',
                  createDate: DateTime.now(),
                  images: [],
                ),
              ),
            ),
          );
          if (result.isNotEmpty) {
            await _fetchData(result, context);
            scanResult = result;
            textController.text = result;
            notifyListeners();
          }
        }
      } else {
        debugPrint('No network connection. Showing error dialog.');
        DialogHelper.showErrorDialog(
          message:
              "Không có kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.",
        );
      }
    } else {
      DialogHelper.showErrorDialog(
        message: "Không có SKU để cập nhật",
      );
    }
  }

  Future<void> navigateToCreateScreen(BuildContext context) async {
    bool isConnected = await networkHelper.isConnected();
    debugPrint('Network connected: $isConnected');

    if (isConnected) {
      if (dataList.isNotEmpty) {
        await checkNavigate(context);
      } else {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateItemScreen(),
          ),
        );
        if (result.isNotEmpty) {
          await _fetchData(result, context);
          scanResult = result;
          textController.text = result;
          notifyListeners();
        }
      }
    } else {
      debugPrint('No network connection. Showing error dialog.');
      DialogHelper.showErrorDialog(
        message: "Không có kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.",
      );
    }
  }

  Future<void> checkNavigate(BuildContext context) async {
    if (dataList.isEmpty) {
      if (unitList.isNotEmpty) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateItemScreen(
              product: ProductModel(
                itemCode: scanResult,
                barCode: '',
                unitOfMeasure: unitList.first,
                length: 0,
                width: 0,
                height: 0,
                weight: 0,
                createBy: '',
                createDate: DateTime.now(),
                images: [],
              ),
              itemCode: scanResult,
            ),
          ),
        );
        if (result.isNotEmpty) {
          await _fetchData(result, context);
          scanResult = result;
          textController.text = result;
          notifyListeners();
        }
      } else if (scanResult.isNotEmpty) {
        DialogHelper.showErrorDialog(
            message: "Không có giá trị đơn vị khả dụng");
      }
    } else if (!containsAllUnits()) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateItemScreen(
            product: dataList[0].copyWith(
              unitOfMeasure: getMissingUnits().first,
            ),
            unitList: getSelectedUnits(),
            itemCode: scanResult,
          ),
        ),
      );
      if (result.isNotEmpty) {
        await _fetchData(result, context);
        scanResult = result;
        textController.text = result;
        notifyListeners();
      }
    } else {
      DialogHelper.showErrorDialog(message: "Tất cả đơn vị đã có giá trị");
    }
  }

  Future<void> checkNavigateAfterScan(BuildContext context) async {
    if (await networkHelper.isConnected()) {
      // Thay thế
      setLoading(true);
      try {
        if (dataList.isEmpty) {
          if (unitList.isNotEmpty) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateItemScreen(
                  product: ProductModel(
                    itemCode: scanResult,
                    barCode: '',
                    unitOfMeasure: unitList.first,
                    length: 0,
                    width: 0,
                    height: 0,
                    weight: 0,
                    createBy: '',
                    createDate: DateTime.now(),
                    images: [],
                  ),
                  itemCode: scanResult,
                ),
              ),
            );
            if (result.isNotEmpty) {
              await _fetchData(result, context);
              scanResult = result;
              textController.text = result;
              notifyListeners();
            }
          }
        } else if (!containsAllUnits()) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateItemScreen(
                product: dataList[0].copyWith(
                  unitOfMeasure: getMissingUnits().first,
                ),
                unitList: getSelectedUnits(),
                itemCode: scanResult,
              ),
            ),
          );
          if (result.isNotEmpty) {
            await _fetchData(result, context);
            scanResult = result;
            textController.text = result;
            notifyListeners();
          }
        }
      } finally {
        setLoading(false);
      }
    } else {
      if (!_networkDialogShown) {
        _networkDialogShown = true;
        DialogHelper.showErrorDialog(message: "Không có kết nối mạng");
      }
    }
  }

  void showImagePreview(BuildContext context, List<ImageViewModel> images) {
    showDialog(
      context: context,
      builder: (context) {
        return ImagePreviewDialog(images: images);
      },
    );
  }

  showAlertDialog(BuildContext context, int productId) {
    Widget cancelButton = CustomButton(
      title: "Bỏ qua",
      btnColor: Colors.blue[400],
      onTap: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = CustomButton(
      title: "Xác nhận",
      btnColor: Colors.red[400],
      onTap: () {
        blockData(productId, context);
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: const Text("Xoá"),
      content: const Text("Bạn có chắc chắn xoá không?"),
      actions: [
        continueButton,
        const SizedBox(
          height: 16,
        ),
        cancelButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> blockData(int productId, BuildContext context) async {
    if (await networkHelper.isConnected()) {
      final result = await apiService.blockData(productId);
      if (result) {
        await onRefresh(context);
      }
    } else if (!_networkDialogShown) {
      _networkDialogShown = true;
      DialogHelper.showErrorDialog(message: "Không có kết nối mạng");
    }
  }
}
