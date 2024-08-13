import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scanner_app/main.dart';

class DialogHelper {
  static void showDioErrorDialog({
    required int? statusCode,
    required String message,
    required dynamic response,
  }) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Lỗi'),
            content: Text(
              'Mã lỗi: $statusCode\n'
              'Chi tiết: $message\n'
              'Phản hồi: $response',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      debugPrint('Error: Unable to show dialog because context is null.');
    }
  }

  static void showSuccessDialog({
    required String message,
  }) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Thành công'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      debugPrint('Error: Unable to show dialog because context is null.');
    }
  }

  static void showErrorDialog({
    required String message,
  }) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Lỗi'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      debugPrint('Error: Unable to show dialog because context is null.');
    }
  }

  void _handleDioError(DioException e) {
    debugPrint('Dio error: ${e.message}');
    final context = navigatorKey.currentContext;
    if (context != null) {
      DialogHelper.showDioErrorDialog(
        statusCode: e.response?.statusCode,
        message: e.message ?? "",
        response: e.response?.data,
      );
    } else {
      debugPrint('Error: Unable to show dialog because context is null.');
    }
  }
}
