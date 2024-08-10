import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_scanner_app/model/data_model.dart';
import 'package:flutter_scanner_app/model/enum.dart';
import 'package:flutter_scanner_app/model/item_model.dart';
import 'package:flutter_scanner_app/model/product_model.dart';
import 'package:flutter_scanner_app/screens/create_item_screen.dart';
import 'package:flutter_scanner_app/service/api_service.dart';
import 'package:flutter_scanner_app/utils/assets.dart';
import 'package:flutter_scanner_app/utils/utils.dart';

class HomeProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();
  late String scanResult = '';
  final TextEditingController textController = TextEditingController();
  late List<ProductModel> dataList = [];
  late List<String> unitList = [];

  Future<void> init(BuildContext context) async {
    // try {
    //   String data = await DefaultAssetBundle.of(context)
    //       .loadString('${AppAsset.assets}mock_second.json');

    //   final Map<String, dynamic> jsonResult = json.decode(data);

    //   ResponseModel dataModel = ResponseModel.fromJson(jsonResult);

    //   listData.addAll(dataModel.products);
    //   notifyListeners();
    // } catch (e) {
    //   // Handle JSON parsing errors or other issues here
    //   print('Error loading data: $e');
    // }

    //get data
    // final data = await apiService.fetchProducts();
    // print("aaaaaaaa ${data.first.barCode}");
  }

  Future<void> handleScanResult(String result, BuildContext context) async {
    scanResult = Utils.handleTSScanResult(result, context);
    textController.text = scanResult;
    notifyListeners();
    await getProductsById(scanResult);
    await getUnitById(scanResult);
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
    final allUnits = UnitModel.values.map((e) => e.name).toSet();
    return allUnits.difference(unitsInList).isEmpty;
  }

  List<String> getMissingUnits() {
    final unitsInList = dataList.map((item) => item.unitOfMeasure).toSet();
    final allUnits = UnitModel.values.map((e) => e.name).toSet();
    return allUnits.difference(unitsInList).toList();
  }

  void navigateToCreateScreen(BuildContext context) {
    if (containsAllUnits()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateItemScreen(),
        ),
      );
    } else {
      if (dataList.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateItemScreen(productModel: dataList[0]),
          ),
        );
      } else {
        // Handle the case where listData is empty
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No items available to pass to CreateItemScreen.')),
        );
      }
    }
  }
}
