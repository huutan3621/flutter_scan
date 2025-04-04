import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scanner_app/utils/enum.dart';
import 'package:flutter_scanner_app/model/product_model.dart';
import 'package:flutter_scanner_app/service/api_service.dart';
import 'package:flutter_scanner_app/utils/network_helper.dart';
import 'package:flutter_scanner_app/utils/permission.dart';
import 'package:flutter_scanner_app/utils/sp_key.dart';
import 'package:flutter_scanner_app/utils/unit_utils.dart';
import 'package:flutter_scanner_app/utils/utils.dart';
import 'package:flutter_scanner_app/widgets/dialog_helper.dart';
import 'package:flutter_scanner_app/widgets/image_review_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateItemProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();
  final formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();
  final List<XFile> images = [];
  late List<String> disableUnitList = [];
  late List<String> unitList = [];
  late bool isBarcodeEnable = true;
  late bool isItemCodeScanEnabled = false;
  final NetworkHelper networkHelper = NetworkHelper();

  // Controllers
  final TextEditingController itemCodeController = TextEditingController();
  // final TextEditingController barCodeController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();

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

  Future<void> init(
    String? itemNumber,
    ProductModel? product,
    List<String>? unitListData,
  ) async {
    //location

    //get unit
    disableUnitList = unitListData ?? [];
    selectedLengthUnit = lengthUnit.last;
    selectedWeightUnit = weightUnit.last;
    //create completely new
    if (itemNumber == null && product == null) {
      isItemCodeScanEnabled = true;
    }
    //check product cases
    if (product != null) {
      itemCodeController.text = product.itemCode;
      // if (product.barCode != "") {
      //   barCodeController.text = product.barCode;
      //   isBarcodeEnable = false;
      // }
      // selectedProductUnit = product.unitOfMeasure;
      selectedLengthUnit = lengthUnit.last;
      selectedWeightUnit = weightUnit.last;
    }
    //have item number but create new
    if (itemNumber != null) {
      await getUnitById(itemNumber);
    }

    setLoading(false);
    notifyListeners();
  }

  Future<void> getUnitById(String itemNumber) async {
    setLoading(true);
    try {
      unitList = await apiService.getUnitById(itemNumber);

      if (unitList.isNotEmpty && isItemCodeScanEnabled == false) {
        final disableUnitSet = disableUnitList.toSet();
        final availableUnits =
            unitList.toSet().difference(disableUnitSet).toList();
        selectedProductUnit = availableUnits.first;
        print('Available units: $availableUnits');
      } else if (unitList.isNotEmpty && isItemCodeScanEnabled == true) {
        await getDisableUnit(itemNumber);
      }
    } catch (e) {
      // DialogHelper.showErrorDialog(
      //     context: context, message: "Có lỗi xã ra, vui lòng thử lại");
    } finally {
      setLoading(false);
    }
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
        selectedProductUnit = unitList.first;
        notifyListeners();
        return;
      }

      // barCodeController.text = listData.first.barCode;
      isBarcodeEnable = false;
      disableUnitList = getSelectedUnits(listData);
      itemNameController.text = listData.first.itemName ?? "";

      if (disableUnitList.isNotEmpty) {
        final missingUnits = getMissingUnits(listData);
        selectedProductUnit = missingUnits.isNotEmpty ? missingUnits.first : '';
        if (disableUnitList.contains(selectedProductUnit)) {
          selectedProductUnit = "";
        }
      }
    } catch (e) {
      // DialogHelper.showErrorDialog(
      //     context: context, message: "Có lỗi xã ra, vui lòng thử lại");
    } finally {
      setLoading(false);
    }
    notifyListeners();
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
    bool isConnected = await networkHelper.isConnected();
    if (!isConnected) {
      showErrorDialog(
        context,
        'Không có kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.',
      );
      return;
    }

    disableUnitList.clear();
    unitList.clear();
    selectedProductUnit = "";
    // barCodeController.clear();
    isBarcodeEnable = true;
    notifyListeners();

    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );

    if (res is String) {
      final scanValue = handleScanResult(res, context);
      itemCodeController.text = scanValue;
      if (scanValue.isNotEmpty) {
        await getUnitById(scanValue);

        if (unitList.isNotEmpty) {
          final listData = await getProductsById(scanValue);
          if (listData.isNotEmpty) {
            // barCodeController.text = listData.first.barCode;
            itemNameController.text = listData.first.itemName ?? "";
            isBarcodeEnable = false;
          }
        }
      }
      notifyListeners();
    }
  }

  Future<void> scanBarCode(BuildContext context) async {
    bool isConnected = await networkHelper.isConnected();
    if (!isConnected) {
      showErrorDialog(
        context,
        'Không có kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.',
      );
      return;
    }

    if (!isBarcodeEnable) {
      showErrorDialog(
        context,
        'Barcode đã tồn tại',
      );
      return;
    }

    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );

    if (res is String && res != '-1') {
      // barCodeController.text = res;
      notifyListeners();
    } else {
      if (res == '-1') {
        // barCodeController.text = "";
        notifyListeners();
        showErrorDialog(context, 'Có lỗi xảy ra khi quét Barcode');
      }
    }
  }

  void chooseUnit(String? value) {
    selectedProductUnit = value ?? "";
    notifyListeners();
  }

  // void chooseImageFromGallery(BuildContext context) async {
  //   if (images.length >= 5) {
  //     showErrorDialog(
  //       context,
  //       'Chỉ cho phép tối đa 5 ảnh',
  //     );
  //     return;
  //   }

  //   final List<XFile> pickedFiles = await picker.pickMultiImage(
  //     maxWidth: 1024,
  //     maxHeight: 1024,
  //     imageQuality: 80,
  //   );

  //   final List<XFile> validImages = [];

  //   for (final pickedFile in pickedFiles) {
  //     final fileSize = await pickedFile.length();

  //     if (fileSize <= 2 * 1024 * 1024) {
  //       validImages.add(pickedFile);
  //     } else {
  //       showErrorDialog(
  //         context,
  //         'Dung lượng ảnh phải dưới 2MB',
  //       );
  //     }
  //   }

  //   if (validImages.isNotEmpty) {
  //     if (images.length + validImages.length <= 5) {
  //       images.addAll(validImages);
  //       notifyListeners();
  //     } else {
  //       showErrorDialog(
  //         context,
  //         'Không thể thêm hơn 5 ảnh',
  //       );
  //     }
  //   }

  //   Navigator.pop(context);
  // }

  // Future<void> chooseImageFromCamera(BuildContext context) async {
  //   if (images.length >= 5) {
  //     showErrorDialog(
  //       context,
  //       'Maximum 5 images allowed',
  //     );
  //     return;
  //   }

  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(
  //     source: ImageSource.camera,
  //     maxWidth: 1024,
  //     maxHeight: 1024,
  //     imageQuality: 80,
  //   );

  //   if (pickedFile != null) {
  //     final fileSize = await pickedFile.length();

  //     if (fileSize <= 2 * 1024 * 1024) {
  //       final tempDir = pickedFile.path;
  //       final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
  //       final tempFile = File('$tempDir/$fileName');

  //       final originalFile = File(pickedFile.path);
  //       await originalFile.copy(tempFile.path);

  //       // Use the copied file
  //       final xFile = XFile(tempFile.path);

  //       images.add(xFile);
  //       notifyListeners();
  //     } else {
  //       showErrorDialog(
  //         context,
  //         'Dung lượng ảnh phải dưới 2MB',
  //       );
  //     }
  //   }
  //   Navigator.pop(context);
  // }

  Future<void> chooseImageFromGallery(BuildContext context) async {
    // if (images.length >= 5) {
    //   showErrorDialog(
    //     context,
    //     'Chỉ cho phép tối đa 5 ảnh',
    //   );
    //   return;
    // }

    final List<XFile> pickedFiles = await picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFiles.isNotEmpty) {
      final List<XFile> validImages = [];
      bool showError = false;

      for (final pickedFile in pickedFiles) {
        final fileSize = await pickedFile.length();

        if (fileSize <= 2 * 1024 * 1024) {
          final savedFile = await _saveImageToAppDirectory(pickedFile);
          if (savedFile != null) {
            validImages.add(savedFile);
          }
        } else {
          showError = true;
          showErrorDialog(
            context,
            'Dung lượng ảnh phải dưới 2MB',
          );
        }
      }

      if (validImages.isNotEmpty) {
        // if (images.length + validImages.length <= 5) {
        images.addAll(validImages);
        notifyListeners();
        // } else {
        //   showError = true;
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     showErrorDialog(
        //       context,
        //       'Không thể thêm hơn 5 ảnh',
        //     );
        //   });
        // }
      }
      if (!showError) {
        Navigator.pop(context);
      }
    } else {
      showErrorDialog(
        context,
        'Có lỗi xảy ra khi thêm ảnh',
      );
      Navigator.pop(context);
    }
  }

  Future<void> chooseImageFromCamera(BuildContext context) async {
    // if (images.length >= 5) {
    //   showErrorDialog(
    //     context,
    //     'Chỉ cho phép tối đa 5 ảnh',
    //   );
    //   return;
    // }

    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final fileSize = await pickedFile.length();

      if (fileSize <= 2 * 1024 * 1024) {
        final savedFile = await _saveImageToAppDirectory(pickedFile);
        if (savedFile != null) {
          images.add(savedFile);
          notifyListeners();
        }
      } else {
        showErrorDialog(
          context,
          'Dung lượng ảnh phải dưới 2MB',
        );
      }
    }
    notifyListeners();

    Navigator.pop(context);
  }

  Future<XFile?> _saveImageToAppDirectory(XFile pickedFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = join(directory.path, fileName);
      final File newFile = File(filePath);

      // Copy the file to the new location
      final File originalFile = File(pickedFile.path);
      await originalFile.copy(newFile.path);

      return XFile(newFile.path);
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  void removeImage(int index) {
    images.removeAt(index);
    notifyListeners();
  }

  void onSubmit(BuildContext context) async {
    setLoading(true);

    try {
      if (formKey.currentState?.validate() == true &&
          selectedProductUnit.isNotEmpty) {
        bool isConnected = await networkHelper.isConnected();
        if (images.isEmpty) {
          showErrorDialog(context, 'Xin vui lòng thêm ảnh, ảnh là bắt buộc');
        }
        if (isConnected && images.isNotEmpty) {
          final bool result = await createItem();
          if (result) {
            Navigator.pop(context, itemCodeController.text);
          }
        }
        if (isConnected == false) {
          showErrorDialog(context,
              'Không có kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.');
        }
      } else {
        showErrorDialog(context, 'Lỗi, xin hãy kiểm tra lại các trường');
      }
    } catch (e) {
      showErrorDialog(context, 'Lỗi xảy ra: $e');
    } finally {
      setLoading(false);
    }
  }

  // Future<bool> createItem() async {
  //   try {
  //     // Convert and parse dimensions
  //     final length = int.parse(UnitUtils.convertLength(
  //         lengthController.text, selectedLengthUnit, LengthUnitEnum.mm.name));
  //     final width = int.parse(UnitUtils.convertLength(
  //         widthController.text, selectedLengthUnit, LengthUnitEnum.mm.name));
  //     final height = int.parse(UnitUtils.convertLength(
  //         heightController.text, selectedLengthUnit, LengthUnitEnum.mm.name));

  //     final weight = weightController.text.isNotEmpty
  //         ? int.parse(UnitUtils.convertWeight(weightController.text,
  //             selectedLengthUnit, WeightUnitEnum.mg.name))
  //         : 0;

  //     final SharedPreferences prefs = await SharedPreferences.getInstance();

  //     final userName = prefs.getString(AppSPKey.userName);

  //     final body = ProductModel(
  //       itemCode: itemCodeController.text,
  //       // itemName: ,
  //       barCode: barCodeController.text,
  //       unitOfMeasure: selectedProductUnit,
  //       length: length,
  //       width: width,
  //       height: height,
  //       weight: weight,
  //       createDate: DateTime.now(),
  //       createBy: userName ?? "App Mobile",
  //     );

  //     final response = await apiService.createItem(body);

  //     if (response.productId != null) {
  //       if (images.isNotEmpty) {
  //         return await uploadImage(response.productId!);
  //       }
  //       return true;
  //     }

  //     return false;
  //   } catch (e) {
  //     debugPrint('Error creating item: $e');
  //     return false;
  //   }
  // }
  Future<bool> createItem() async {
    try {
      final length = int.parse(UnitUtils.convertLength(
          lengthController.text, selectedLengthUnit, LengthUnitEnum.mm.name));
      final width = int.parse(UnitUtils.convertLength(
          widthController.text, selectedLengthUnit, LengthUnitEnum.mm.name));
      final height = int.parse(UnitUtils.convertLength(
          heightController.text, selectedLengthUnit, LengthUnitEnum.mm.name));

      final weight = weightController.text.isNotEmpty
          ? int.parse(UnitUtils.convertWeight(weightController.text,
              selectedLengthUnit, WeightUnitEnum.mg.name))
          : 0;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString(AppSPKey.userName) ?? "App Mobile";

      FormData formData = FormData.fromMap({
        "ItemCode": itemCodeController.text,
        "UnitOfMeasure": selectedProductUnit,
        "Length": length.toString(),
        "Width": width.toString(),
        "Height": height.toString(),
        "Weight": weight.toString(),
        "CreateBy": userName,
      });

      for (var image in images) {
        formData.files.add(MapEntry(
          "files",
          await MultipartFile.fromFile(image.path, filename: image.name),
        ));
      }

      // // Gửi request
      // final response = await dio.post(
      //   '$baseUrl/api/ScanProduct/create-scan-product-data',
      //   data: formData,
      //   options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      // );

      // if (response.statusCode == 200) {
      //   return true;
      // } else {
      //   _handleErrorDialog("Có lỗi xảy ra. Mã lỗi: ${response.statusCode}");
      //   return false;
      // }
      final respose = await apiService.postFormData(formData);
      if (respose != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error creating item: $e');
      return false;
    }
  }

  Future<bool> uploadImage(int productId) async {
    return await apiService.updateProductImage(productId, images);
  }

  void showErrorDialog(BuildContext context, String message) {
    DialogHelper.showErrorDialog(
      message: message,
    );
  }

  void showSuccessDialog(BuildContext context, String message) {
    DialogHelper.showSuccessDialog(
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
