// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemModel _$ItemModelFromJson(Map<String, dynamic> json) => ItemModel(
      itemCode: json['itemCode'] as String,
      barCode: json['barCode'] as String,
      unit: json['unit'] as String,
      length: json['length'] as String,
      width: json['width'] as String,
      height: json['height'] as String,
      weight: json['weight'] as String,
      image: json['image'] as String,
    );

Map<String, dynamic> _$ItemModelToJson(ItemModel instance) => <String, dynamic>{
      'itemCode': instance.itemCode,
      'barCode': instance.barCode,
      'unit': instance.unit,
      'length': instance.length,
      'width': instance.width,
      'height': instance.height,
      'weight': instance.weight,
      'image': instance.image,
    };
