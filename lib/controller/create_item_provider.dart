import 'package:flutter/material.dart';
import 'package:flutter_scanner_app/model/enum.dart';
import 'package:flutter_scanner_app/model/product_model.dart';
import 'package:flutter_scanner_app/service/api_service.dart';
import 'package:flutter_scanner_app/utils/unit_utils.dart';
import 'package:flutter_scanner_app/utils/utils.dart';
import 'package:flutter_scanner_app/widgets/dialog_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class CreateItemProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();

  final formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();
  final List<XFile> images = [];
  final List<ProductModel> listData = [];
  List<String> unitList = [];
  late bool isBarcodeEnable = true;
  late bool isItemCodeScanEnabled = false;

  //controllers
  final TextEditingController itemCodeController = TextEditingController();
  final TextEditingController barCodeController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  List<String> lengthUnit = LengthUnitEnum.values.map((e) => e.name).toList();
  List<String> weightUnit = WeightUnitEnum.values.map((e) => e.name).toList();

  //selected unit
  String selectedLengthUnit = "";
  String selectedWidthUnit = "";
  String selectedHeightUnit = "";
  String selectedWeightUnit = "";

  Future<void> init(String? itemNumber, ProductModel? product,
      List<String>? unitListData) async {
    if (itemNumber == null && product == null) {
      isItemCodeScanEnabled = true;
      notifyListeners();
    }
    if (product != null) {
      itemCodeController.text = product.itemCode;
      if (product.barCode != "") {
        barCodeController.text = product.barCode;
        isBarcodeEnable = false;
      }
      unitController.text = product.unitOfMeasure;
      unitList = unitListData ?? [];
      notifyListeners();
    }
  }

  Future<void> getUnitById(String itemNumber) async {
    unitList = await apiService.getUnitById(itemNumber);
    notifyListeners();
  }

  String handleScanResult(String result, BuildContext context) {
    return Utils.handleTSScanResult(result, context);
  }

  void updateSelectedLengthUnit(String previousValue, String currentValue) {
    selectedLengthUnit = currentValue;
    lengthController.text = UnitUtils.convertLength(
        lengthController.text, previousValue, currentValue);
    notifyListeners();
  }

  void updateSelectedWidthUnit(String previousValue, String currentValue) {
    selectedWidthUnit = currentValue;
    widthController.text = UnitUtils.convertLength(
        widthController.text, previousValue, currentValue);
    notifyListeners();
  }

  void updateSelectedHeightUnit(String previousValue, String currentValue) {
    selectedHeightUnit = currentValue;
    heightController.text = UnitUtils.convertLength(
        heightController.text, previousValue, currentValue);
    notifyListeners();
  }

  void updateSelectedWeightUnit(String previousValue, String currentValue) {
    selectedWeightUnit = currentValue;
    weightController.text = UnitUtils.convertWeight(
        weightController.text, previousValue, currentValue);
    notifyListeners();
  }

  Future<void> scanItemCode(BuildContext context) async {
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );
    if (res is String) {
      itemCodeController.text = handleScanResult(res, context);
      await getUnitById(res);
      unitController.text = unitList.first;
      notifyListeners();
    }
  }

  Future<void> scanBarCode(BuildContext context) async {
    if (isBarcodeEnable == false) {
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
      barCodeController.text = res;
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

    final List<XFile> pickedFiles = await picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    final List<XFile> validImages = [];

    for (final pickedFile in pickedFiles) {
      final fileSize = await pickedFile.length();

      if (fileSize <= 2 * 1024 * 1024) {
        // 2MB
        validImages.add(pickedFile);
      } else {
        _showDialog(
          context,
          'Image size must be less than 2MB',
        );
      }
    }

    if (validImages.isNotEmpty) {
      if (images.length + validImages.length <= 5) {
        images.addAll(validImages);
        notifyListeners();
      } else {
        _showDialog(
          context,
          'Cannot add more than 5 images in total',
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

  void onSubmit(BuildContext context) {
    if (formKey.currentState!.validate()) {
      createItem();
    } else {
      _showDialog(context, 'Please fix the errors in the form');
    }
    createItem();
  }

  Future<void> createItem() async {
    ProductModel body = ProductModel(
      itemCode: itemCodeController.text,
      barCode: barCodeController.text,
      unitOfMeasure: unitController.text,
      length: int.parse(UnitUtils.convertLength(
          lengthController.text, selectedLengthUnit, LengthUnitEnum.mm.name)),
      width: int.parse(UnitUtils.convertLength(
          widthController.text, selectedWidthUnit, LengthUnitEnum.mm.name)),
      height: int.parse(UnitUtils.convertLength(
          heightController.text, selectedHeightUnit, LengthUnitEnum.mm.name)),
      weight: int.parse(UnitUtils.convertWeight(
          weightController.text, selectedWeightUnit, WeightUnitEnum.g.name)),
      createBy: "User",
    );
    final response = await apiService.createItem(body);
    print("aaa ${response.productId}");
    uploadImage(response.productId ?? 0);
    // uploadImage(50);
  }

  Future<void> uploadImage(int productId) async {
    final response = apiService.updateProductImage(productId, images);
    print(response);
  }

  void _showDialog(BuildContext context, String message) {
    DialogHelper.showErrorDialog(
      context: context,
      message: message,
    );
  }
}
