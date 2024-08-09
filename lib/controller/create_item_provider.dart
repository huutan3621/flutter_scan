import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_scanner_app/model/data_model.dart';
import 'package:flutter_scanner_app/model/enum.dart';
import 'package:flutter_scanner_app/model/item_model.dart';
import 'package:flutter_scanner_app/model/product_model.dart';
import 'package:flutter_scanner_app/utils/assets.dart';
import 'package:flutter_scanner_app/utils/unit_utils.dart';
import 'package:flutter_scanner_app/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class CreateItemProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();
  final List<XFile> images = [];
  final List<ProductModel> listData = [];

  //controller
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

  //mock data, will remove when have api
  List<String> unitList = UnitModel.values.map((e) => e.name).toList();

  Future<void> init(BuildContext context) async {
    String data = await DefaultAssetBundle.of(context)
        .loadString('${AppAsset.assets}mock.json');

    final Map<String, dynamic> jsonResult = json.decode(data);

    ResponseModel dataModel = ResponseModel.fromJson(jsonResult);

    for (ProductModel e in dataModel.products) {
      listData.add(e);
    }

    //selected unit
    selectedLengthUnit = lengthUnit.first;
    selectedHeightUnit = lengthUnit.first;
    selectedWidthUnit = lengthUnit.first;
    selectedWeightUnit = weightUnit.first;
  }

  String handleScanResult(String result, BuildContext context) {
    return Utils.handleTSScanResult(result, context);
  }

  void updateSelectedLengthUnit(String previousValue, String currentValue) {
    selectedLengthUnit = currentValue;
    lengthController.text = UnitUtils.convertUnit(
            double.parse(lengthController.text), previousValue, currentValue)
        .toString();
    notifyListeners();
  }

  void updateSelectedWidthUnit(String previousValue, String currentValue) {
    selectedWidthUnit = currentValue;
    widthController.text = UnitUtils.convertUnit(
            double.parse(widthController.text), previousValue, currentValue)
        .toString();
    notifyListeners();
  }

  void updateSelectedWeightUnit(String previousValue, String currentValue) {
    selectedWeightUnit = currentValue;
    weightController.text = UnitUtils.convertWeightUnit(
            double.parse(weightController.text), previousValue, currentValue)
        .toString();
    notifyListeners();
  }

  Future<void> scanItemCode(context) async {
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

  Future<void> scanBarCode(context) async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 images allowed')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image size must be less than 2MB')),
        );
      }
    }
  }

  void chooseImageFromCamera(BuildContext context) async {
    if (images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 images allowed')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image size must be less than 2MB')),
        );
      }
    }
  }
}
