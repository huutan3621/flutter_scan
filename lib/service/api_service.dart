import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_scanner_app/model/warehouse_model.dart';
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
        return 'https://dev.scanproduct.trungsoncare.com';
      case Environment.staging:
        return 'https://staging.scanproduct.trungsoncare.com';
      case Environment.production:
      default:
        return 'https://scanproduct.trungsoncare.com';
    }
  }

  Future<T> _retry<T>(Future<T> Function() action) async {
    int attempt = 0;
    while (attempt < retryCount) {
      try {
        return await action();
      } on DioException catch (e) {
        attempt++;
        if (attempt == retryCount) {
          _handleDioError(e);
          rethrow;
        }
      } catch (e) {
        attempt++;
        if (attempt == retryCount) {
          debugPrint('Unexpected error: $e');
          rethrow; // rethrow unexpected errors
        }
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
        return responseData.products ?? [];
      } else {
        _handleErrorDialog("Có lỗi xảy ra. Mã lỗi: ${response.data}");
        throw ApiException(
            'Failed to load products. Status code: ${response.statusCode}');
      }
    });
  }

  Future<List<ProductModel>> getProductsById(String itemNumber) async {
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
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('result') &&
            responseData['result'] is List<dynamic>) {
          final List<dynamic> jsonList = responseData['result'];
          return jsonList
              .map((jsonItem) => ProductModel.fromJson(jsonItem))
              .toList();
        } else {
          throw ApiException('Invalid response format');
        }
      } else {
        _handleErrorDialog("Có lỗi xảy ra. Mã lỗi: ${response.data}");
        throw ApiException(
            'Failed to load products. Status code: ${response.statusCode}');
      }
    });
  }

  Future<bool> scanProductAddLocation(
      String locationCode, String scanCode, String scanBy) async {
    _logRequest(
      '$baseUrl/api/v2/Warehouse/scan-product',
      {
        'locationCode': locationCode,
        'scanCode': scanCode,
        'createBy': scanBy,
      },
    );

    final response = await dio.post(
      '$baseUrl/api/v2/Warehouse/scan-product',
      data: {
        'locationCode': locationCode,
        'scanCode': scanCode,
        'createBy': scanBy,
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    _logResponse(response);

    if (response.statusCode == 200) {
      return true;
    } else {
      _handleErrorDialog("Có lỗi xảy ra. Mã lỗi: ${response.statusCode}");
      return false;
    }
  }

  Future<WarehouseResponse> fetchProducts({
    required int pageNumber,
    required int pageSize,
    String? itemNumber,
  }) async {
    return _retry(() async {
      final endpoint =
          '$baseUrl/api/v2/Warehouse/products?pageNumber=$pageNumber&pageSize=$pageSize${itemNumber != null ? '&itemNumber=$itemNumber' : ''}';

      _logRequest(endpoint, null);

      final response = await dio.get(
        endpoint,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      _logResponse(response);

      if (response.statusCode == 200) {
        // Deserialize response using WarehouseResponse
        return WarehouseResponse.fromJson(response.data);
      } else {
        _handleErrorDialog(
            "Có lỗi xảy ra. Mã lỗi: ${response.statusCode} - ${response.statusMessage}");
        throw ApiException(
            'Failed to fetch products. Status code: ${response.statusCode}');
      }
    });
  }

  Future<List<String>> getUnitById(String itemNumber) async {
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
        final responseData = response.data;
        final List<dynamic> jsonResult = responseData['result'];

        return jsonResult.map((item) => item.toString()).toList();

        // return jsonResult.map((item) => item.toString()).toList();
      } else {
        _handleErrorDialog("Có lỗi xảy ra. Mã lỗi: ${response.data}");
        throw ApiException(
            'Failed to load units. Status code: ${response.statusCode}');
      }
    });
  }

  Future<ProductModel> createItem(ProductModel body) async {
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

  Future<Response?> postFormData(FormData formData) async {
    final response = await dio.post(
      '$baseUrl/api/ScanProduct/create-scan-product-data',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      _handleErrorDialog("Có lỗi xảy ra. Mã lỗi: ${response.statusCode}");
      return null;
    }
  }

  Future<bool> updateProductImage(int productId, List<XFile> images) async {
    return _retry(() async {
      final formData = FormData.fromMap({
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

  Future<bool> blockData(int productId) async {
    final url =
        '$baseUrl/api/ScanProduct/block-scan-product-data?productId=$productId';

    return _retry(() async {
      _logRequest(url, null);

      final response = await dio.post(url);

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
    final context = navigatorKey.currentContext;
    String message;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout, please try again.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout, please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout, please try again.';
        break;
      case DioExceptionType.badResponse:
        message =
            'Server error: ${e.response?.statusCode} ${e.response?.statusMessage}';
        break;
      case DioExceptionType.cancel:
        message = 'Request canceled.';
        break;
      case DioExceptionType.unknown:
      default:
        message = e.message ?? 'Unknown error occurred.';
        break;
    }

    debugPrint('Dio error: $message');
    if (context != null) {
      DialogHelper.showDioErrorDialog(
        statusCode: e.response?.statusCode,
        message: message,
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
