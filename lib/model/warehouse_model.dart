import 'package:json_annotation/json_annotation.dart';

part 'warehouse_model.g.dart';

@JsonSerializable(explicitToJson: true)
class WarehouseResponse {
  final int? totalCount;
  final int? pageSize;
  final int? currentPage;
  final int? totalPages;
  final List<LocationData>? data;

  WarehouseResponse({
    this.totalCount,
    this.pageSize,
    this.currentPage,
    this.totalPages,
    this.data,
  });

  factory WarehouseResponse.fromJson(Map<String, dynamic> json) =>
      _$WarehouseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WarehouseResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LocationData {
  final String? locationCode;
  final List<Product>? products;

  LocationData({
    this.locationCode,
    this.products,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) =>
      _$LocationDataFromJson(json);

  Map<String, dynamic> toJson() => _$LocationDataToJson(this);
}

@JsonSerializable()
class Product {
  final String? itemCode;
  final String? barCode;
  final String? createBy;

  Product({
    this.itemCode,
    this.barCode,
    this.createBy,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
