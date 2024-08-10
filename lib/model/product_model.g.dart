// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponseModel _$ResponseModelFromJson(Map<String, dynamic> json) =>
    ResponseModel(
      totalCount: (json['totalCount'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      products: (json['products'] as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ResponseModelToJson(ResponseModel instance) =>
    <String, dynamic>{
      'totalCount': instance.totalCount,
      'pageSize': instance.pageSize,
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
      'products': instance.products,
    };

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      itemCode: json['itemCode'] as String,
      barCode: json['barCode'] as String,
      unitOfMeasure: json['unitOfMeasure'] as String,
      length: (json['length'] as num).toInt(),
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      weight: (json['weight'] as num).toInt(),
      createDate: json['createDate'] == null
          ? null
          : DateTime.parse(json['createDate'] as String),
      createBy: json['createBy'] as String,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => ImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      productId: (json['productId'] as num?)?.toInt(),
      block: json['block'] as bool?,
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'itemCode': instance.itemCode,
      'barCode': instance.barCode,
      'unitOfMeasure': instance.unitOfMeasure,
      'length': instance.length,
      'width': instance.width,
      'height': instance.height,
      'weight': instance.weight,
      'createDate': instance.createDate?.toIso8601String(),
      'createBy': instance.createBy,
      'images': instance.images,
      'productId': instance.productId,
      'block': instance.block,
    };

ImageModel _$ImageModelFromJson(Map<String, dynamic> json) => ImageModel(
      imageId: (json['imageId'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      type: json['type'] as String,
      name: json['name'] as String,
      size: json['size'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$ImageModelToJson(ImageModel instance) =>
    <String, dynamic>{
      'imageId': instance.imageId,
      'productId': instance.productId,
      'type': instance.type,
      'name': instance.name,
      'size': instance.size,
      'url': instance.url,
    };
