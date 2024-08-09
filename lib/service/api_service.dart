import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_scanner_app/model/product_model.dart'; // Adjust the import according to your project structure

class ApiService {
  final String baseUrl;
  final http.Client client;

  ApiService({
    this.baseUrl = 'https://scanproduct.trungsonpharma.com',
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<List<ProductModel>> fetchProducts() async {
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
}
