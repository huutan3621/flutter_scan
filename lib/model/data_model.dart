import 'package:flutter_scanner_app/model/item_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_model.g.dart';

@JsonSerializable()
class DataModel {
  @JsonKey(name: "id")
  final String id;
  @JsonKey(name: "data")
  final List<ItemModel> listData;

  DataModel({
    required this.id,
    required this.listData,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) =>
      _$DataModelFromJson(json);

  Map<String, dynamic> toJson() => _$DataModelToJson(this);
}
