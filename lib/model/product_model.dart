import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ResponseModel {
  @JsonKey(name: "totalCount")
  final int? totalCount;
  @JsonKey(name: "pageSize")
  final int? pageSize;
  @JsonKey(name: "currentPage")
  final int? currentPage;
  @JsonKey(name: "totalPages")
  final int? totalPages;
  @JsonKey(name: "products")
  final List<ProductModel>? products;

  ResponseModel({
    this.totalCount,
    this.pageSize,
    this.currentPage,
    this.totalPages,
    this.products,
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
  @JsonKey(name: "itemName")
  final String? itemName;
  @JsonKey(name: "barCode")
  final String? barCode;
  @JsonKey(name: "unitOfMeasure")
  final String unitOfMeasure;
  @JsonKey(name: "length")
  final int length;
  @JsonKey(name: "width")
  final int width;
  @JsonKey(name: "height")
  final int height;
  @JsonKey(name: "weight")
  final int? weight;
  @JsonKey(name: "createDate")
  final DateTime? createDate;
  @JsonKey(name: "createBy")
  final String createBy;
  @JsonKey(name: "images")
  final List<ImageViewModel>? images;
  @JsonKey(name: "productId")
  final int? productId;
  @JsonKey(name: "block")
  final bool? block;

  ProductModel({
    required this.itemCode,
    this.itemName,
    this.barCode,
    required this.unitOfMeasure,
    required this.length,
    required this.width,
    required this.height,
    this.weight,
    this.createDate,
    required this.createBy,
    this.images,
    this.productId,
    this.block,
  });

  ProductModel copyWith({
    String? itemCode,
    String? itemName,
    String? barCode,
    String? unitOfMeasure,
    int? length,
    int? width,
    int? height,
    int? weight,
    DateTime? createDate,
    String? createBy,
    List<ImageViewModel>? images,
    int? productId,
    bool? block,
  }) =>
      ProductModel(
        itemCode: itemCode ?? this.itemCode,
        itemName: itemName ?? this.itemName,
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
class ImageViewModel {
  @JsonKey(name: "imageId")
  final int? imageId;
  @JsonKey(name: "productId")
  final int? productId;
  @JsonKey(name: "type")
  final String? type;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "size")
  final String? size;
  @JsonKey(name: "url")
  final String? url;

  ImageViewModel({
    this.imageId,
    this.productId,
    this.type,
    this.name,
    this.size,
    this.url,
  });

  ImageViewModel copyWith({
    int? imageId,
    int? productId,
    String? type,
    String? name,
    String? size,
    String? url,
  }) =>
      ImageViewModel(
        imageId: imageId ?? this.imageId,
        productId: productId ?? this.productId,
        type: type ?? this.type,
        name: name ?? this.name,
        size: size ?? this.size,
        url: url ?? this.url,
      );

  factory ImageViewModel.fromJson(Map<String, dynamic> json) =>
      _$ImageViewModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImageViewModelToJson(this);
}
