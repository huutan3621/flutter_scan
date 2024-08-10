import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_scanner_app/model/product_model.dart'; // Adjust the import according to your project structure
import 'dart:async';
import 'dart:isolate';
import 'dart:io'; // For File
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart'; // For MediaType

class ApiService {
  final String baseUrl;
  final http.Client client;

  ApiService({
    this.baseUrl = 'https://scanproduct.trungsoncare.com/',
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await client.get(
        Uri.parse(
            '$baseUrl/api/ScanProduct/get-scan-product-data?pageNumber=1&pageSize=10'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResult = json.decode(response.body);
        final ResponseModel responseData = ResponseModel.fromJson(jsonResult);
        return responseData.products;
      } else {
        throw Exception(
          'Failed to load products. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      rethrow;
    }
  }

  //scan item
  Future<List<ProductModel>> getProductsById(String itemNumber) async {
    try {
      final response = await client.get(Uri.parse(
          '$baseUrl/api/ScanProduct/get-scan-product-data-by-item-number/$itemNumber'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        final List<ProductModel> products = jsonList
            .map((jsonItem) => ProductModel.fromJson(jsonItem))
            .toList();

        return products;
      } else {
        throw Exception(
            'Failed to load products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      rethrow;
    }
  }

  Future<List<String>> getUnitById(String itemNumber) async {
    try {
      final response = await client
          .get(
            Uri.parse(
                '$baseUrl/api/ScanProduct/get-unit-measure-by-item-number/$itemNumber'),
          )
          .timeout(const Duration(seconds: 30)); // Adjust timeout as needed

      if (response.statusCode == 200) {
        final List<dynamic> jsonResult = json.decode(response.body);
        return jsonResult.map((item) => item.toString()).toList();
      } else {
        throw Exception(
            'Failed to load units. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching units: $e');
      rethrow;
    }
  }

  //create item
  Future<ProductModel> createItem(ProductModel body) async {
    try {
      final response = await client
          .post(
            Uri.parse('$baseUrl/api/ScanProduct/create-scan-product-data'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return ProductModel.fromJson(jsonResponse);
      } else {
        throw Exception(
            'Failed to load units. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating item: $e');
      rethrow;
    }
  }

  //upload image
  Future<bool> updateProductImage(int productId, List<XFile> images) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/ScanProduct/update-scan-product-image'),
      );

      request.fields['productId'] = productId.toString();

      for (var file in images) {
        final mimeType =
            lookupMimeType(file.path) ?? 'application/octet-stream';
        final mediaType = MediaType.parse(mimeType);

        var multipartFile = await http.MultipartFile.fromPath(
          'files',
          file.path,
          contentType: mediaType,
        );
        request.files.add(multipartFile);
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint(
            'Failed to update product image. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating product image: $e');
      rethrow;
    }
  }
}
