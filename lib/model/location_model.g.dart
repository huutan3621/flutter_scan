// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationModel _$LocationModelFromJson(Map<String, dynamic> json) =>
    LocationModel(
      locationCode: json['locationCode'] as String?,
      scanCode: json['scanCode'] as String?,
      createBy: json['createBy'] as String?,
    );

Map<String, dynamic> _$LocationModelToJson(LocationModel instance) =>
    <String, dynamic>{
      'locationCode': instance.locationCode,
      'scanCode': instance.scanCode,
      'createBy': instance.createBy,
    };
