import 'package:flutter/material.dart';

import 'package:flutter_scanner_app/model/product_model.dart';
import 'package:flutter_scanner_app/screens/create_item_screen.dart';
import 'package:flutter_scanner_app/service/api_service.dart';
import 'package:flutter_scanner_app/utils/utils.dart';

import 'package:flutter_scanner_app/widgets/dialog_helper.dart';

class HomeProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();
  late String scanResult = '';
  final TextEditingController textController = TextEditingController();
  late List<ProductModel> dataList = [];
  late List<String> unitList = [];

  Future<void> init(BuildContext context) async {}

  Future<void> changeResult() async {}

  Future<void> handleScanResult(String result, BuildContext context) async {
    scanResult = Utils.handleTSScanResult(result, context);
    textController.text = scanResult;
    notifyListeners();
    if (scanResult != "") {
      await getProductsById(scanResult);
      await getUnitById(scanResult);
    } else {
      dataList.clear();
      unitList.clear();
      notifyListeners();
    }
  }

  Future<void> getProductsById(String itemNumber) async {
    dataList = await apiService.getProductsById(itemNumber);
    notifyListeners();
  }

  Future<void> getUnitById(String itemNumber) async {
    unitList = await apiService.getUnitById(itemNumber);
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

  Future<void> navigateToCreateScreen(BuildContext context) async {
    if (scanResult.isNotEmpty) {
      await checkNavigate(context);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateItemScreen(
            unitList: [],
          ),
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
              unitList: unitList,
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
            unitList: getMissingUnits(),
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

  void showImagePreviewDialog(
      BuildContext context, List<ImageViewModel> images) {
    final PageController pageController = PageController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                // Large image view
                Expanded(
                  flex: 3,
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        images[index].url ?? "",
                        fit: BoxFit.cover,
                      );
                    },
                    onPageChanged: (index) {
                      pageController.jumpToPage(index);
                    },
                  ),
                ),
                // Small image preview list
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          pageController.jumpToPage(index);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Image.network(
                            images[index].url ?? "",
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            scale: pageController.page == index ? 1.1 : 1.0,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
