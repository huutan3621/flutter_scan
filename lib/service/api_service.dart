import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_scanner_app/main.dart';
import 'package:flutter_scanner_app/widgets/dialog_helper.dart';
import 'package:flutter_scanner_app/model/product_model.dart';

enum Environment { development, staging, production }

class ApiService {
  final Environment environment;
  final String baseUrl;
  final Dio dio;
  final Connectivity connectivity;
  final int retryCount;

  ApiService({
    this.environment = Environment.production,
    Dio? dio,
    Connectivity? connectivity,
    this.retryCount = 3,
  })  : baseUrl = _getBaseUrl(environment),
        dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            ),
        connectivity = connectivity ?? Connectivity();

  static String _getBaseUrl(Environment environment) {
    switch (environment) {
      case Environment.development:
        return 'https://dev.scanproduct.trungsoncare.com/';
      case Environment.staging:
        return 'https://staging.scanproduct.trungsoncare.com/';
      case Environment.production:
      default:
        return 'https://scanproduct.trungsoncare.com/';
    }
  }

  Future<bool> _checkNetworkConnection() async {
    var connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _handleErrorDialog(
          "Không có kết nối mạng. Vui lòng kiểm tra lại kết nối.");
      return false;
    }
    return true;
  }

  Future<T> _retry<T>(Future<T> Function() action) async {
    int attempt = 0;
    while (attempt < retryCount) {
      try {
        return await action();
      } catch (e) {
        attempt++;
        if (attempt == retryCount) rethrow;
      }
    }
    return Future.error('Retry failed');
  }

  void _logRequest(String url, dynamic data) {
    debugPrint('Requesting: $url');
    if (data != null) {
      debugPrint('Data: $data');
    }
  }

  void _logResponse(Response response) {
    debugPrint('Response: ${response.statusCode}');
    debugPrint('Response data: ${response.data}');
  }

  Future<List<ProductModel>> getProducts(
      {int pageNumber = 1, int pageSize = 10}) async {
    if (!await _checkNetworkConnection()) return [];

    return _retry(() async {
      _logRequest('$baseUrl/api/ScanProduct/get-scan-product-data', {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      });

      final response = await dio.get(
        '$baseUrl/api/ScanProduct/get-scan-product-data',
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      _logResponse(response);

      if (response.statusCode == 200) {
        final responseData = ResponseModel.fromJson(response.data);
        return responseData.products;
      } else {
        _handleErrorDialog("Có lỗi xảy ra. Mã lỗi: ${response.data}");
        throw ApiException(
            'Failed to load products. Status code: ${response.statusCode}');
      }
    });
  }

  Future<List<ProductModel>> getProductsById(String itemNumber) async {
    if (!await _checkNetworkConnection()) return [];

    return _retry(() async {
      _logRequest(
          '$baseUrl/api/ScanProduct/get-scan-product-data-by-item-number/$itemNumber',
          null);

      final response = await dio.get(
          '$baseUrl/api/ScanProduct/get-scan-product-data-by-item-number/$itemNumber',
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ));

      _logResponse(response);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList
            .map((jsonItem) => ProductModel.fromJson(jsonItem))
            .toList();
      } else {
        _handleErrorDialog("Có lỗi xảy ra. Mã lỗi: ${response.data}");
        throw ApiException(
            'Failed to load products. Status code: ${response.statusCode}');
      }
    });
  }

  Future<List<String>> getUnitById(String itemNumber) async {
    if (!await _checkNetworkConnection()) return [];

    return _retry(() async {
      _logRequest(
          '$baseUrl/api/ScanProduct/get-unit-measure-by-item-number/$itemNumber',
          null);

      final response = await dio.get(
        '$baseUrl/api/ScanProduct/get-unit-measure-by-item-number/$itemNumber',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      _logResponse(response);

      if (response.statusCode == 200) {
        final List<dynamic> jsonResult = response.data;
        return jsonResult.map((item) => item.toString()).toList();
      } else {
        _handleErrorDialog("Có lỗi xảy ra. Mã lỗi: ${response.data}");
        throw ApiException(
            'Failed to load units. Status code: ${response.statusCode}');
      }
    });
  }

  Future<ProductModel> createItem(ProductModel body) async {
    if (!await _checkNetworkConnection()) {
      throw NetworkException("No network connection");
    }

    return _retry(() async {
      _logRequest('$baseUrl/api/ScanProduct/create-scan-product-data', body);

      final response = await dio.post(
        '$baseUrl/api/ScanProduct/create-scan-product-data',
        data: body.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      _logResponse(response);

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      } else {
        _handleErrorDialog("Có lỗi xảy ra. Mã lỗi: ${response.data}");
        throw ApiException(
            'Failed to create item. Status code: ${response.statusCode}');
      }
    });
  }

  Future<bool> updateProductImage(int productId, List<XFile> images) async {
    if (!await _checkNetworkConnection()) return false;

    return _retry(() async {
      _logRequest('$baseUrl/api/ScanProduct/update-scan-product-image', {
        'productId': productId.toString(),
        'files': images,
      });

      FormData formData = FormData.fromMap({
        'productId': productId.toString(),
        'files': await Future.wait(images.map((file) async {
          final fileName = file.path.split('/').last;
          final fileBytes = await file.readAsBytes();
          return MultipartFile.fromBytes(fileBytes, filename: fileName);
        })),
      });

      final response = await dio.post(
        '$baseUrl/api/ScanProduct/update-scan-product-image',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      _logResponse(response);

      if (response.statusCode == 200) {
        return true;
      } else {
        _handleErrorDialog("Có lỗi xảy ra. Mã lỗi: ${response.data}");
        return false;
      }
    });
  }

  Future<bool> blockData(
      String itemCode, String barCode, String unitOfMeasure) async {
    if (!await _checkNetworkConnection()) return false;

    final url = '$baseUrl/api/ScanProduct/block-scan-product-data';

    return _retry(() async {
      _logRequest(url, {
        'itemCode': itemCode,
        'barCode': barCode,
        'unitOfMeasure': unitOfMeasure,
      });

      final response = await dio.post(
        url,
        queryParameters: {
          'itemCode': itemCode,
          'barCode': barCode,
          'unitOfMeasure': unitOfMeasure,
        },
      );

      _logResponse(response);

      if (response.statusCode == 200) {
        _handleSuccessDialog("Xoá thành công");
        return true;
      } else {
        _handleErrorDialog("Có lỗi xảy ra. Mã lỗi: ${response.data}");
        return false;
      }
    });
  }

  void _handleSuccessDialog(String message) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      DialogHelper.showSuccessDialog(
        message: message,
      );
    } else {
      debugPrint('Error: Unable to show dialog because context is null.');
    }
  }

  void _handleErrorDialog(String message) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      DialogHelper.showErrorDialog(
        message: message,
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
        message: e.message ?? 'Unknown error occurred',
        response: e.response?.data,
      );
    } else {
      debugPrint('Error: Unable to show dialog because context is null.');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}
