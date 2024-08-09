import 'package:json_annotation/json_annotation.dart';

part 'item_model.g.dart';

@JsonSerializable()
class ItemModel {
  @JsonKey(name: "itemCode")
  final String itemCode;
  @JsonKey(name: "barCode")
  final String barCode;
  @JsonKey(name: "unit")
  final String unit;
  @JsonKey(name: "length")
  final String length;
  @JsonKey(name: "width")
  final String width;
  @JsonKey(name: "height")
  final String height;
  @JsonKey(name: "weight")
  final String weight;
  @JsonKey(name: "image")
  final String image;

  ItemModel({
    required this.itemCode,
    required this.barCode,
    required this.unit,
    required this.length,
    required this.width,
    required this.height,
    required this.weight,
    required this.image,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItemModelToJson(this);
}
