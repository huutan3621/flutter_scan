import 'dart:convert';

class UpdateProductImageData {
  final int productId;

  UpdateProductImageData({required this.productId});

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
    };
  }

  String toJson() {
    return json.encode(toMap());
  }
}
