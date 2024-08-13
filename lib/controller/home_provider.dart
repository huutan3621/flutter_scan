import 'package:flutter/material.dart';

import 'package:flutter_scanner_app/model/product_model.dart';
import 'package:flutter_scanner_app/screens/create_item_screen.dart';
import 'package:flutter_scanner_app/service/api_service.dart';
import 'package:flutter_scanner_app/utils/utils.dart';
import 'package:flutter_scanner_app/widgets/custom_button.dart';

import 'package:flutter_scanner_app/widgets/dialog_helper.dart';
import 'package:flutter_scanner_app/widgets/image_review_dialog.dart';

class HomeProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();
  late String scanResult = '';
  final TextEditingController textController = TextEditingController();
  late List<ProductModel> dataList = [];
  late List<String> unitList = [];
  bool isLoading = false;

  Future<void> init(BuildContext context) async {}

  Future<void> setLoading(bool value) async {
    isLoading = value;
    notifyListeners();
  }

  Future<void> handleScanResult(String result, BuildContext context) async {
    scanResult = Utils.handleTSScanResult(result, context);
    textController.text = scanResult;
    notifyListeners();
    if (scanResult != "") {
      await getProductsById(scanResult);
      await getUnitById(scanResult);
      await checkNavigateAfterScan(context);
    } else {
      dataList.clear();
      unitList.clear();
      notifyListeners();
    }
  }

  Future<void> getProductsById(String itemNumber) async {
    await setLoading(true);
    dataList = await apiService.getProductsById(itemNumber);
    await setLoading(false);
    notifyListeners();
  }

  Future<void> getUnitById(String itemNumber) async {
    await setLoading(true);
    unitList = await apiService.getUnitById(itemNumber);
    await setLoading(false);
    notifyListeners();
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

  Future<void> navigateToCreateScreen(BuildContext context) async {
    if (scanResult.isNotEmpty) {
      await checkNavigate(context);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateItemScreen(),
        ),
      );
    }
  }

  Future<void> checkNavigate(BuildContext context) async {
    if (dataList.isEmpty) {
      // Trường hợp 1: dataList chưa có item nào
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
        if (result == 'refresh' && scanResult.isNotEmpty) {
          await getProductsById(scanResult);
        }
      } else {
        DialogHelper.showErrorDialog(
            context: context, message: "No available item.");
      }
    } else if (!containsAllUnits()) {
      // Trường hợp 2: dataList còn thiếu đơn vị đo lường nào
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
      if (result == 'refresh' && scanResult.isNotEmpty) {
        await getProductsById(scanResult);
      }
    } else {
      // Trường hợp 3: dataList chứa tất cả đơn vị đo lường
      DialogHelper.showErrorDialog(
          context: context, message: "All item units are included");
    }
  }

  Future<void> checkNavigateAfterScan(BuildContext context) async {
    if (dataList.isEmpty) {
      // Trường hợp 1: dataList chưa có item nào
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
        if (result == 'refresh' && scanResult.isNotEmpty) {
          await getProductsById(scanResult);
        }
      } else {
        DialogHelper.showErrorDialog(
            context: context, message: "No available item.");
      }
    } else if (!containsAllUnits()) {
      // Trường hợp 2: dataList còn thiếu đơn vị đo lường nào
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
      if (result == 'refresh' && scanResult.isNotEmpty) {
        await getProductsById(scanResult);
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
}
