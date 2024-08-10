import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ResponseModel {
  @JsonKey(name: "totalCount")
  final int totalCount;
  @JsonKey(name: "pageSize")
  final int pageSize;
  @JsonKey(name: "currentPage")
  final int currentPage;
  @JsonKey(name: "totalPages")
  final int totalPages;
  @JsonKey(name: "products")
  final List<ProductModel> products;

  ResponseModel({
    required this.totalCount,
    required this.pageSize,
    required this.currentPage,
    required this.totalPages,
    required this.products,
  });

  ResponseModel copyWith({
    int? totalCount,
    int? pageSize,
    int? currentPage,
    int? totalPages,
    List<ProductModel>? products,
  }) =>
      ResponseModel(
        totalCount: totalCount ?? this.totalCount,
        pageSize: pageSize ?? this.pageSize,
        currentPage: currentPage ?? this.currentPage,
        totalPages: totalPages ?? this.totalPages,
        products: products ?? this.products,
      );

  factory ResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseModelToJson(this);
}

@JsonSerializable()
class ProductModel {
  @JsonKey(name: "itemCode")
  final String itemCode;
  @JsonKey(name: "barCode")
  final String barCode;
  @JsonKey(name: "unitOfMeasure")
  final String unitOfMeasure;
  @JsonKey(name: "length")
  final int length;
  @JsonKey(name: "width")
  final int width;
  @JsonKey(name: "height")
  final int height;
  @JsonKey(name: "weight")
  final int weight;
  @JsonKey(name: "createDate")
  final DateTime? createDate;
  @JsonKey(name: "createBy")
  final String createBy;
  @JsonKey(name: "images")
  final List<ImageModel>? images;
  @JsonKey(name: "productId")
  final int? productId;
  @JsonKey(name: "block")
  final bool? block;

  ProductModel({
    required this.itemCode,
    required this.barCode,
    required this.unitOfMeasure,
    required this.length,
    required this.width,
    required this.height,
    required this.weight,
    this.createDate,
    required this.createBy,
    this.images,
    this.productId,
    this.block,
  });

  ProductModel copyWith({
    String? itemCode,
    String? barCode,
    String? unitOfMeasure,
    int? length,
    int? width,
    int? height,
    int? weight,
    DateTime? createDate,
    String? createBy,
    List<ImageModel>? images,
    int? productId,
    bool? block,
  }) =>
      ProductModel(
        itemCode: itemCode ?? this.itemCode,
        barCode: barCode ?? this.barCode,
        unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
        length: length ?? this.length,
        width: width ?? this.width,
        height: height ?? this.height,
        weight: weight ?? this.weight,
        createDate: createDate ?? this.createDate,
        createBy: createBy ?? this.createBy,
        images: images ?? this.images,
        productId: productId ?? this.productId,
        block: block ?? this.block,
      );

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}

@JsonSerializable()
class ImageModel {
  @JsonKey(name: "imageId")
  final int imageId;
  @JsonKey(name: "productId")
  final int productId;
  @JsonKey(name: "type")
  final String type;
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "size")
  final String size;
  @JsonKey(name: "url")
  final String url;

  ImageModel({
    required this.imageId,
    required this.productId,
    required this.type,
    required this.name,
    required this.size,
    required this.url,
  });

  ImageModel copyWith({
    int? imageId,
    int? productId,
    String? type,
    String? name,
    String? size,
    String? url,
  }) =>
      ImageModel(
        imageId: imageId ?? this.imageId,
        productId: productId ?? this.productId,
        type: type ?? this.type,
        name: name ?? this.name,
        size: size ?? this.size,
        url: url ?? this.url,
      );

  factory ImageModel.fromJson(Map<String, dynamic> json) =>
      _$ImageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImageModelToJson(this);
}
