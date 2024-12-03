import 'package:flutter/material.dart';
import 'package:flutter_scanner_app/main.dart';
import 'package:flutter_scanner_app/widgets/dialog_helper.dart';

class Utils {
  // static String handleScanResult(String result, BuildContext context) {
  //   if (isValidQRCode(result) || isValidBarcode(result)) {
  //     return result;
  //   } else if (isValidTextFormat(result)) {
  //     return result = extractNumberFromText(result);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Mã quét không hợp lệ.')),
  //     );
  //     return "";
  //   }
  // }

  static String handleTSScanResult(String result, BuildContext context) {
    if (isValidQRCode(result)) {
      return result;
    } else if (isValidTextFormat(result)) {
      return result = extractNumberFromText(result);
    } else {
      if (result == "-1") {
        return "";
      }
      return result;
    }
  }

  static String handleTSScanLocation(String result, BuildContext context) {
    if (isValidLocation(result)) {
      return result;
    } else {
      showErrorDialog("Vị trí không khả dụng");
      return "";
    }
  }

  static void showErrorDialog(String message) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      DialogHelper.showErrorDialog(
        message: message,
      );
    } else {
      debugPrint('Error: Unable to show dialog because context is null.');
    }
  }

  static bool isValidQRCode(String code) {
    final regex = RegExp(r'^9\d{5}$');
    return regex.hasMatch(code);
  }

  static bool isValidBarcode(String code) {
    final regex = RegExp(r'^\d{11,13}$'); // 11 - 13 digits in barcode
    return regex.hasMatch(code);
  }

  static bool isValidTextFormat(String text) {
    final regex = RegExp(r'^9\d{5};');
    return regex.hasMatch(text);
  }

  static String extractNumberFromText(String text) {
    final match = RegExp(r'^9\d{5}').firstMatch(text);
    return match?.group(0) ?? '';
  }

  static bool isValidLocation(String code) {
    String pattern = r'^[a-zA-Z0-9]{3}-\d{4}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(code);
  }
}
