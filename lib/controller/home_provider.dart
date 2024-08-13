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

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> onRefresh(BuildContext context) async {
    await getProductsById(textController.text, context);
    await getUnitById(textController.text, context);
    setLoading(false);
    notifyListeners();
  }

  Future<void> handleScanResult(String result, BuildContext context) async {
    scanResult = Utils.handleTSScanResult(result, context);
    textController.text = scanResult;
    notifyListeners();
    if (scanResult.isNotEmpty) {
      await getProductsById(scanResult, context);
      await getUnitById(scanResult, context);
    } else {
      dataList.clear();
      unitList.clear();
      notifyListeners();
    }
    await checkNavigateAfterScan(context);
  }

  Future<void> getProductsById(String itemNumber, BuildContext context) async {
    // setLoading(true);
    // try {
    dataList = await apiService.getProductsById(itemNumber);
    //   notifyListeners();
    // } catch (e) {
    //   // DialogHelper.showErrorDialog(
    //   //     context: context, message: "Có lỗi xã ra, vui lòng thử lại");
    // } finally {
    // setLoading(false);
    // }
  }

  Future<void> getUnitById(String itemNumber, BuildContext context) async {
    // setLoading(true);
    // try {
    unitList = await apiService.getUnitById(itemNumber);
    notifyListeners();
    // } catch (e) {
    //   // DialogHelper.showErrorDialog(
    //   //     context: context, message: "Có lỗi xã ra, vui lòng thử lại");
    // } finally {
    // setLoading(false);
    // }
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

  Future<void> cleanAndNavigateToCreateScreen(BuildContext context) async {
    scanResult = "";
    textController.clear();
    dataList.clear();
    unitList.clear();
    notifyListeners();
    await navigateToCreateScreen(context);
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
          await getProductsById(scanResult, context);
        }
      } else {
        DialogHelper.showErrorDialog(
            context: context, message: "Không có giá trị đơn vị kả dụng");
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
        await getProductsById(scanResult, context);
      }
    } else {
      // Trường hợp 3: dataList chứa tất cả đơn vị đo lường
      DialogHelper.showErrorDialog(
          context: context, message: "Tất cả đơn vị đã có giá trị");
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
          await getProductsById(scanResult, context);
        }
      } else {
        DialogHelper.showErrorDialog(
            context: context, message: "Không có giá trị đơn vị khả dụng");
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
        await getProductsById(scanResult, context);
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

  showAlertDialog(BuildContext context, String itemCode, String barCode,
      String unitOfMeasure) {
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
        blockData(itemCode, barCode, unitOfMeasure, context);
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
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> blockData(String itemCode, String barCode, String unitOfMeasure,
      BuildContext context) async {
    final result = await apiService.blockData(itemCode, barCode, unitOfMeasure);
    if (result) {
      await onRefresh(context);
    }
  }
}
