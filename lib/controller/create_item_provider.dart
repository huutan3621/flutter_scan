import 'package:flutter/material.dart';
import 'package:flutter_scanner_app/utils/enum.dart';
import 'package:flutter_scanner_app/model/product_model.dart';
import 'package:flutter_scanner_app/service/api_service.dart';
import 'package:flutter_scanner_app/utils/unit_utils.dart';
import 'package:flutter_scanner_app/utils/utils.dart';
import 'package:flutter_scanner_app/widgets/dialog_helper.dart';
import 'package:flutter_scanner_app/widgets/image_review_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class CreateItemProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();
  final formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();
  final List<XFile> images = [];
  late List<String> disableUnitList = [];
  late List<String> unitList = [];
  late bool isBarcodeEnable = true;
  late bool isItemCodeScanEnabled = false;

  // Controllers
  final TextEditingController itemCodeController = TextEditingController();
  final TextEditingController barCodeController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  // Selected unit
  String selectedLengthUnit = "";
  String selectedWeightUnit = "";
  String selectedProductUnit = "";

  // Available units
  List<String> lengthUnit = LengthUnitEnum.values.map((e) => e.name).toList();
  List<String> weightUnit = WeightUnitEnum.values.map((e) => e.name).toList();

  //loading
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> init(String? itemNumber, ProductModel? product,
      List<String>? unitListData) async {
    //create completely new
    if (itemNumber == null && product == null) {
      isItemCodeScanEnabled = true;
      notifyListeners();
    }
    //check product cases
    if (product != null) {
      itemCodeController.text = product.itemCode;
      if (product.barCode != "") {
        barCodeController.text = product.barCode;
        isBarcodeEnable = false;
      }
      selectedProductUnit = product.unitOfMeasure;
      selectedLengthUnit = lengthUnit.last;
      selectedWeightUnit = weightUnit.last;
      notifyListeners();
    }
    //have item number but create new
    if (itemNumber != null) {
      await getUnitById(itemNumber);
      await getDisableUnit(itemNumber);
    }
    //get unit
    disableUnitList = unitListData ?? [];
    selectedLengthUnit = lengthUnit.last;
    selectedWeightUnit = weightUnit.last;
    notifyListeners();
  }

  Future<void> getUnitById(String itemNumber) async {
    setLoading(true);
    unitList = await apiService.getUnitById(itemNumber);
    if (unitList.isNotEmpty) {
      selectedProductUnit = unitList.first;
    }
    if (isItemCodeScanEnabled) {
      await getDisableUnit(itemNumber);
    }
    setLoading(false);
    notifyListeners();
  }

  Future<List<ProductModel>> getProductsById(String itemNumber) async {
    return await apiService.getProductsById(itemNumber);
  }

  Future<void> getDisableUnit(String itemNumber) async {
    setLoading(true);

    try {
      final listData = await getProductsById(itemNumber);

      if (listData.isEmpty) {
        disableUnitList = [];
        selectedProductUnit = '';
        return;
      }

      disableUnitList = getSelectedUnits(listData);
      print(disableUnitList);

      final missingUnits = getMissingUnits(listData);
      selectedProductUnit = missingUnits.isNotEmpty ? missingUnits.first : '';
      if (disableUnitList.contains(selectedProductUnit)) {
        selectedProductUnit = "";
      }
      print("selected unit: $selectedProductUnit");
    } catch (e) {
      debugPrint('Error getting disable unit: $e');
      disableUnitList = [];
      selectedProductUnit = '';
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  List<String> getMissingUnits(List<ProductModel> listData) {
    final unitsInList = listData.map((item) => item.unitOfMeasure).toSet();
    final allUnits = unitList.toSet();
    return allUnits.difference(unitsInList).toList();
  }

  List<String> getSelectedUnits(List<ProductModel> listData) {
    final unitsInList = listData.map((item) => item.unitOfMeasure).toSet();
    final allUnits = unitList.toSet();
    return unitsInList.intersection(allUnits).toList();
  }

  String handleScanResult(String result, BuildContext context) {
    return Utils.handleTSScanResult(result, context);
  }

  void updateSelectedUnit(String previousValue, String currentValue) {
    selectedLengthUnit = currentValue;
    lengthController.text = UnitUtils.convertLength(
        lengthController.text, previousValue, selectedLengthUnit);
    widthController.text = UnitUtils.convertLength(
        widthController.text, previousValue, selectedLengthUnit);
    heightController.text = UnitUtils.convertLength(
        heightController.text, previousValue, selectedLengthUnit);
    notifyListeners();
  }

  void updateSelectedWeightUnit(String previousValue, String currentValue) {
    selectedWeightUnit = currentValue;
    weightController.text = UnitUtils.convertWeight(
        weightController.text, previousValue, selectedWeightUnit);
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
      final scanValue = handleScanResult(res, context);
      itemCodeController.text = scanValue;
      if (scanValue != "") {
        await getUnitById(scanValue);
      }
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
      final isValidCode = Utils.isValidBarcode(res);
      if (isValidCode) {
        barCodeController.text = res;
      } else {
        _showDialog(context, "Invalid scan code");
      }
      notifyListeners();
    }
  }

  void chooseUnit(String? value) {
    selectedProductUnit = value ?? "";
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
      final fileSize = await pickedFile.length();

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

  void removeImage(int index) {
    images.removeAt(index);
    notifyListeners();
  }

  void onSubmit(BuildContext context) async {
    setLoading(true);

    if (formKey.currentState!.validate() && selectedProductUnit != "") {
      try {
        final bool = await createItem();
        if (bool == true) {
          Navigator.pop(context, 'refresh');
        }
      } catch (e) {}
    } else {
      _showDialog(context, 'Error. Please check the form again');
    }
    setLoading(false);
  }

  Future<bool> createItem() async {
    try {
      // Convert and parse dimensions
      final length = int.parse(UnitUtils.convertLength(
          lengthController.text, selectedLengthUnit, LengthUnitEnum.mm.name));
      final width = int.parse(UnitUtils.convertLength(
          widthController.text, selectedLengthUnit, LengthUnitEnum.mm.name));
      final height = int.parse(UnitUtils.convertLength(
          heightController.text, selectedLengthUnit, LengthUnitEnum.mm.name));

      final weight = weightController.text.isNotEmpty
          ? int.parse(UnitUtils.convertWeight(
              weightController.text, selectedLengthUnit, WeightUnitEnum.g.name))
          : 0;

      final body = ProductModel(
        itemCode: itemCodeController.text,
        barCode: barCodeController.text,
        unitOfMeasure: selectedProductUnit,
        length: length,
        width: width,
        height: height,
        weight: weight,
        createDate: DateTime.now(),
        createBy: "App Mobile",
      );

      final response = await apiService.createItem(body);

      if (response.productId != null) {
        if (images.isNotEmpty) {
          return await uploadImage(response.productId!);
        }
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error creating item: $e');
      return false;
    }
  }

  Future<bool> uploadImage(int productId) async {
    return await apiService.updateProductImage(productId, images);
  }

  void _showDialog(BuildContext context, String message) {
    DialogHelper.showErrorDialog(
      context: context,
      message: message,
    );
  }

  void showImagePreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return ImagePreviewDialog(images: images);
      },
    );
  }
}
