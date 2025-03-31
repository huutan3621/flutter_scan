// import 'package:ai_barcode/ai_barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scanner_app/model/product_model.dart';
import 'package:flutter_scanner_app/screens/create_item_screen.dart';
import 'package:flutter_scanner_app/service/api_service.dart';
import 'package:flutter_scanner_app/utils/network_helper.dart';
import 'package:flutter_scanner_app/utils/sp_key.dart';
import 'package:flutter_scanner_app/utils/utils.dart';
import 'package:flutter_scanner_app/widgets/custom_button.dart';
import 'package:flutter_scanner_app/widgets/dialog_helper.dart';
import 'package:flutter_scanner_app/widgets/image_review_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class HomeProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();
  final NetworkHelper networkHelper = NetworkHelper();
  late String scanLocation = '';
  late String scanProduct = '';
  late String? userName = '';

  final TextEditingController locationController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();

  late List<ProductModel> dataList = [];
  late List<String> unitList = [];
  bool isLoading = false;
  bool _networkDialogShown = false;
  String locationData = "";

  Future<void> init(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    userName = prefs.getString(AppSPKey.userName);

    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> onRefresh(BuildContext context) async {
    dataList.clear();
    unitList.clear();
    await _fetchData(locationController.text, scanProduct, context);
  }

  Future<void> locationToScanScreen(BuildContext context) async {
    bool isConnected = await networkHelper.isConnected();
    debugPrint('Network connected: $isConnected');

    if (isConnected) {
      locationData = "";
      notifyListeners();
      var res = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SimpleBarcodeScannerPage(),
        ),
      );
      if (res is String) {
        handleScanLocation(res, context);
      }
    } else {
      debugPrint('No network connection. Showing error dialog.');
      DialogHelper.showErrorDialog(
        message: "Không có kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.",
      );
    }
  }

  Future<void> updateUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final userInput = userNameController.text.trim();

    final bool isValid = RegExp(r'^NS\d+$').hasMatch(userInput);

    if (!isValid) {
      DialogHelper.showErrorDialog(
        message: "Mã nhân sự không hợp lệ, vui lòng thử lại",
      );
      return;
    }

    final isDone = await prefs.setString(AppSPKey.userName, userInput);

    if (isDone) {
      userName = userInput;
    }
    notifyListeners();
  }

  Future<void> productToScanScreen(BuildContext context) async {
    bool isConnected = await networkHelper.isConnected();
    debugPrint('Network connected: $isConnected');

    if (isConnected) {
      // if (locationController.text != "") {
      locationData = "";
      var res = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SimpleBarcodeScannerPage(),
        ),
      );
      if (res is String) {
        handleScanProduct(res, context);
      }
      // }
      //  else {
      //   debugPrint('No location data.');
      //   DialogHelper.showErrorDialog(
      //     message: "Không có dữ liệu vị trí, vui lòng thử lại.",
      //   );
      // }
    } else {
      debugPrint('No network connection. Showing error dialog.');
      DialogHelper.showErrorDialog(
        message: "Không có kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.",
      );
    }
  }

  Future<void> handleScanLocation(String result, BuildContext context) async {
    scanLocation = Utils.handleTSScanLocation(result, context);
    locationController.text = scanLocation;
    notifyListeners();
    if (scanLocation.isNotEmpty) {
      // await _fetchData(scanLocation, context);
    } else {
      dataList.clear();
      unitList.clear();
      notifyListeners();
    }
    // await checkNavigateAfterScan(context);
  }

  Future<void> handleScanProduct(String result, BuildContext context) async {
    scanProduct = Utils.handleTSScanResult(result, context);
    productController.text = scanProduct;
    notifyListeners();
    if (scanProduct.isNotEmpty) {
      await _fetchData(scanLocation, scanProduct, context);
    } else {
      dataList.clear();
      unitList.clear();
      notifyListeners();
    }
    // await checkNavigateAfterScan(context);
  }

  Future<void> _fetchData(
      String locationCode, String scanCode, BuildContext context) async {
    if (await networkHelper.isConnected()) {
      _networkDialogShown = false;

      try {
        await Future.wait([
          apiService.getProductsById(scanCode).then((data) => dataList = data),
          apiService.getUnitById(scanCode).then((units) => unitList = units),
          apiService.fetchProducts(
              pageNumber: 1, pageSize: 10, itemNumber: scanCode),
          // .then((value) =>
          //     locationData = value.data?.first.locationCode ?? ""),
        ]);
        notifyListeners();
      } catch (e) {
        // Handle exception if needed
      } finally {}
    } else if (!_networkDialogShown) {
      _networkDialogShown = true;
      DialogHelper.showErrorDialog(message: "Không có kết nối mạng");
    }
  }

  Future<void> updateLocation(BuildContext context) async {
    if (locationData == "") {
      final result = await apiService.scanProductAddLocation(
          scanLocation, scanProduct, userName ?? "App Mobile");
      if (result) {
        DialogHelper.showSuccessDialog(message: "Thêm vị trí thành công");
      }
      await _fetchData(scanLocation, scanProduct, context);
    }
  }

  @override
  void dispose() {
    productController.dispose();
    locationController.dispose();
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
      // if (locationController.text != "") {
      scanProduct = "";
      productController.clear();
      locationData = "";
      dataList.clear();
      unitList.clear();
      notifyListeners();
      await navigateToCreateScreen(context);
      // }
      // else {
      //   DialogHelper.showErrorDialog(
      //     message: "Không có dữ liệu vị trí, vui lòng thử lại",
      //   );
      // }
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

    if (scanProduct.isNotEmpty) {
      if (isConnected) {
        if (dataList.isNotEmpty) {
          await checkNavigate(context);
        } else {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateItemScreen(
                itemCode: scanProduct,
                product: ProductModel(
                  itemCode: scanProduct,
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
            await _fetchData(locationController.text, result, context);
            scanProduct = result;
            productController.text = result;
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
    }
    // else if (locationController.text == "") {
    //   DialogHelper.showErrorDialog(
    //     message: "Không có dữ liệu vị trí, vui lòng thử lại",
    //   );
    // }
    else {
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
          await _fetchData(locationController.text, result, context);
          scanProduct = result;
          productController.text = result;
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
                itemCode: scanProduct,
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
              itemCode: scanProduct,
            ),
          ),
        );
        if (result.isNotEmpty) {
          await _fetchData(locationController.text, result, context);
          scanProduct = result;
          productController.text = result;
          notifyListeners();
        }
      } else if (scanProduct.isNotEmpty) {
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
            itemCode: scanProduct,
          ),
        ),
      );
      if (result.isNotEmpty) {
        await _fetchData(locationController.text, result, context);
        scanProduct = result;
        productController.text = result;
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
        if (dataList.isEmpty && locationController.text == locationData) {
          if (unitList.isNotEmpty) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateItemScreen(
                  product: ProductModel(
                    itemCode: scanProduct,
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
                  itemCode: scanProduct,
                ),
              ),
            );
            if (result.isNotEmpty) {
              await _fetchData(locationController.text, result, context);
              scanProduct = result;
              productController.text = result;
              notifyListeners();
            }
          }
        } else if (!containsAllUnits() &&
            locationController.text == locationData) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateItemScreen(
                product: dataList[0].copyWith(
                  unitOfMeasure: getMissingUnits().first,
                ),
                unitList: getSelectedUnits(),
                itemCode: scanProduct,
              ),
            ),
          );
          if (result.isNotEmpty) {
            await _fetchData(locationController.text, result, context);
            scanProduct = result;
            productController.text = result;
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
