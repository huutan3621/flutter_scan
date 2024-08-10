import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_scanner_app/model/product_model.dart'; // Adjust the import according to your project structure
import 'dart:async';
import 'dart:isolate';

class ApiService {
  final String baseUrl;
  final http.Client client;

  ApiService({
    this.baseUrl = 'https://scanproduct.trungsoncare.com/',
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await client.get(Uri.parse(
          '$baseUrl/api/ScanProduct/get-scan-product-data?pageNumber=1&pageSize=10'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResult = json.decode(response.body);
        final ResponseModel responseData = ResponseModel.fromJson(jsonResult);
        return responseData.products;
      } else {
        throw Exception(
            'Failed to load products. Status code: ${response.statusCode}');
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

  //get unit
  Future<List<String>> getUnitById(String itemNumber) async {
    try {
      final response = await client.get(Uri.parse(
          '$baseUrl/api/ScanProduct/get-unit-measure-by-item-number/$itemNumber'));

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
}
