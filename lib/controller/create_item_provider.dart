import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_scanner_app/model/data_model.dart';
import 'package:flutter_scanner_app/model/enum.dart';
import 'package:flutter_scanner_app/model/item_model.dart';
import 'package:flutter_scanner_app/model/product_model.dart';
import 'package:flutter_scanner_app/service/api_service.dart';
import 'package:flutter_scanner_app/utils/assets.dart';
import 'package:flutter_scanner_app/utils/unit_utils.dart';
import 'package:flutter_scanner_app/utils/utils.dart';
import 'package:flutter_scanner_app/widgets/dialog_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'dart:io'; // For File
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For MediaType

class CreateItemProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();
  final List<XFile> images = [];
  final List<ProductModel> listData = [];

  final ApiService apiService = ApiService();

  //controllers
  final TextEditingController itemCodeController = TextEditingController();
  final TextEditingController barCodeController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController lengthController =
      TextEditingController(text: "0");
  final TextEditingController widthController =
      TextEditingController(text: "0");
  final TextEditingController heightController =
      TextEditingController(text: "0");
  final TextEditingController weightController =
      TextEditingController(text: "0");

  List<String> lengthUnit = LengthUnitEnum.values.map((e) => e.name).toList();
  List<String> weightUnit = WeightUnitEnum.values.map((e) => e.name).toList();

  String selectedLengthUnit = "";
  String selectedWidthUnit = "";
  String selectedHeightUnit = "";
  String selectedWeightUnit = "";

  List<String> unitList = [];

  Future<void> init(ProductModel? productModel, List<String>? unitList) async {
    itemCodeController.text = productModel?.itemCode ?? "";
    barCodeController.text = productModel?.barCode ?? "";
    unitController.text = productModel?.unitOfMeasure ?? "";
    this.unitList = unitList ?? [];
    notifyListeners(); // Notify listeners to update the UI
  }

  String handleScanResult(String result, BuildContext context) {
    return Utils.handleTSScanResult(result, context);
  }

  void updateSelectedLengthUnit(String previousValue, String currentValue) {
    selectedLengthUnit = currentValue;
    lengthController.text = UnitUtils.convertUnit(
            int.parse(lengthController.text), previousValue, currentValue)
        .toString();
    notifyListeners();
  }

  void updateSelectedWidthUnit(String previousValue, String currentValue) {
    selectedWidthUnit = currentValue;
    widthController.text = UnitUtils.convertUnit(
            int.parse(widthController.text), previousValue, currentValue)
        .toString();
    notifyListeners();
  }

  void updateSelectedHeightUnit(String previousValue, String currentValue) {
    selectedHeightUnit = currentValue;
    heightController.text = UnitUtils.convertUnit(
            int.parse(heightController.text), previousValue, currentValue)
        .toString();
    notifyListeners();
  }

  void updateSelectedWeightUnit(String previousValue, String currentValue) {
    selectedWeightUnit = currentValue;
    weightController.text = UnitUtils.convertWeightUnit(
            int.parse(weightController.text), previousValue, currentValue)
        .toString();
    notifyListeners();
  }

  Future<void> scanItemCode(BuildContext context) async {
    if (itemCodeController.text.isNotEmpty) {
      _showDialog(
        context,
        'Item Code is already set. Scanning is not allowed.',
      );
      return;
    }

    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );
    if (res is String) {
      itemCodeController.text = handleScanResult(res, context);
      notifyListeners();
    }
  }

  Future<void> scanBarCode(BuildContext context) async {
    if (barCodeController.text.isNotEmpty) {
      _showDialog(
        context,
        'Barcode is already set. Scanning is not allowed.',
      );
      return;
    }

    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );
    if (res is String) {
      barCodeController.text = handleScanResult(res, context);
      notifyListeners();
    }
  }

  void chooseUnit(String? value) {
    unitController.text = value ?? "";
    notifyListeners();
  }

  void chooseImageFromGallery(BuildContext context) async {
    if (images.length >= 5) {
      _showDialog(
        context,
        'Maximum 5 images allowed',
      );
      return;
    }

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final fileSize = await pickedFile.length(); // Get file size

      if (fileSize <= 2 * 1024 * 1024) {
        images.add(pickedFile);
        notifyListeners();
      } else {
        _showDialog(
          context,
          'Image size must be less than 2MB',
        );
      }
    }
    Navigator.pop(context);
  }

  void chooseImageFromCamera(BuildContext context) async {
    if (images.length >= 5) {
      _showDialog(
        context,
        'Maximum 5 images allowed',
      );
      return;
    }

    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final fileSize = await pickedFile.length(); // Get file size

      if (fileSize <= 2 * 1024 * 1024) {
        images.add(pickedFile);
        notifyListeners();
      } else {
        _showDialog(
          context,
          'Image size must be less than 2MB',
        );
      }
    }
    Navigator.pop(context);
  }

  Future<void> createItem() async {
    ProductModel body = ProductModel(
      itemCode: itemCodeController.text,
      barCode: barCodeController.text,
      unitOfMeasure: unitController.text,
      length: int.parse(lengthController.text),
      width: int.parse(widthController.text),
      weight: int.parse(weightController.text),
      height: int.parse(heightController.text),
      createBy: "User",
    );
    final response = await apiService.createItem(body);
    print("aaa ${response.productId}");
    uploadImage(response.productId ?? 0);
    // uploadImage(21);
  }

  Future<void> uploadImage(int productId) async {
    final response = apiService.updateProductImage(productId, images);
    print(response);
  }

  void _showDialog(BuildContext context, String message) {
    DialogHelper.showSuccessDialog(
      context: context,
      message: message,
    );
  }
}
