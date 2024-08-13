import 'package:dio/dio.dart';
import 'package:flutter_scanner_app/main.dart';
import 'package:flutter_scanner_app/widgets/dialog_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_scanner_app/model/product_model.dart'; // Adjust the import according to your project structure

class ApiService {
  final String baseUrl = 'https://scanproduct.trungsoncare.com';
  final Dio dio;

  ApiService({
    Dio? dio,
  }) : dio = dio ?? Dio();

  Future<List<ProductModel>> getProducts(
      {int pageNumber = 1, int pageSize = 10}) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/ScanProduct/get-scan-product-data',
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final responseData = ResponseModel.fromJson(response.data);
        return responseData.products;
      } else {
        throw Exception(
            'Failed to load products. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      debugPrint('Error fetching products: $e');
      rethrow;
    }
  }

  Future<List<ProductModel>> getProductsById(String itemNumber) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/ScanProduct/get-scan-product-data-by-item-number/$itemNumber',
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList
            .map((jsonItem) => ProductModel.fromJson(jsonItem))
            .toList();
      } else {
        throw Exception(
            'Failed to load products. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleErrorDialog(e.response?.data);
      rethrow;
    } catch (e) {
      debugPrint('Error fetching products: $e');
      rethrow;
    }
  }

  Future<List<String>> getUnitById(String itemNumber) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/ScanProduct/get-unit-measure-by-item-number/$itemNumber',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResult = response.data;
        return jsonResult.map((item) => item.toString()).toList();
      } else {
        throw Exception(
            'Failed to load units. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleErrorDialog(e.response?.data);
      rethrow;
    } catch (e) {
      debugPrint('Error fetching units: $e');
      rethrow;
    }
  }

  Future<ProductModel> createItem(ProductModel body) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/ScanProduct/create-scan-product-data',
        data: body.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to create item. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleErrorDialog(
          "Error. Please try again: ${e.response?.statusMessage}");
      rethrow;
    } catch (e) {
      debugPrint('Error creating item: $e');
      rethrow;
    }
  }

  // Future<bool> updateProductImage(int productId, List<XFile> images) async {
  //   try {
  //     FormData formData = FormData();

  //     formData.fields.add(MapEntry('productId', productId.toString()));

  //     for (var file in images) {
  //       final fileName = file.path.split('/').last;
  //       final fileBytes = await file.readAsBytes();

  //       formData.files.add(MapEntry(
  //         'files',
  //         MultipartFile.fromBytes(
  //           fileBytes,
  //           filename: fileName,
  //         ),
  //       ));
  //     }

  //     final response = await dio.post(
  //       '$baseUrl/api/ScanProduct/update-scan-product-image',
  //       data: formData,
  //       options: Options(headers: {'Content-Type': 'multipart/form-data'}),
  //     );

  //     if (response.statusCode == 200) {
  //       _handleSuccessDialog("Upload image successfully");
  //       return true;
  //     } else {
  //       debugPrint(
  //           'Failed to update product image. Status code: ${response.statusCode}');
  //       debugPrint('Response body: ${response.data}');
  //       return false;
  //     }
  //   } on DioException catch (e) {
  //     _handleDioError(e);
  //     rethrow;
  //   } catch (e) {
  //     debugPrint('Error updating product image: $e');
  //     rethrow;
  //   }
  // }
  Future<bool> updateProductImage(int productId, List<XFile> images) async {
    try {
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

      if (response.statusCode == 200) {
        // _handleSuccessDialog("Upload image successfully");
        return true;
      } else {
        debugPrint(
            'Failed to update product image. Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      _handleErrorDialog(e.response?.data);
      rethrow;
    } catch (e) {
      debugPrint('Error updating product image: $e');
      rethrow;
    }
  }

  Future<bool> blockData(
      String itemCode, String barCode, String unitOfMeasure) async {
    final dio = Dio();
    final url = '$baseUrl/api/ScanProduct/block-scan-product-data';

    try {
      final response = await dio.post(
        url,
        queryParameters: {
          'itemCode': itemCode,
          'barCode': barCode,
          'unitOfMeasure': unitOfMeasure,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      if (response.statusCode == 200) {
        _handleSuccessDialog("Delete successfully");
        return true;
      } else {
        debugPrint('Failed to delete. Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      _handleErrorDialog(e.response?.data);
      rethrow;
    } catch (e) {
      debugPrint('Error updating product image: $e');
      rethrow;
    }
  }

  void _handleSuccessDialog(String message) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      DialogHelper.showSuccessDialog(
        context: context,
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
        context: context,
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
        context: context,
        statusCode: e.response?.statusCode,
        message: e.message ?? 'Unknown error occurred',
        response: e.response?.data,
      );
    } else {
      debugPrint('Error: Unable to show dialog because context is null.');
    }
  }
}
