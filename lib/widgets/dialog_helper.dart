import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scanner_app/main.dart';

class DialogHelper {
  static void showErrorDialog({
    required BuildContext context,
    required int? statusCode,
    required String message,
    required dynamic response,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(
            'Failed with status code: $statusCode\n'
            'Message: $message\n'
            'Response: $response',
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
  }

  static void showSuccessDialog({
    required BuildContext context,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
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
  }

  void _handleDioError(DioException e) {
    debugPrint('Dio error: ${e.message}');
    final context = navigatorKey.currentContext;
    if (context != null) {
      DialogHelper.showErrorDialog(
        context: context,
        statusCode: e.response?.statusCode,
        message: e.message ?? "",
        response: e.response?.data,
      );
    } else {
      debugPrint('Error: Unable to show dialog because context is null.');
    }
  }
}
