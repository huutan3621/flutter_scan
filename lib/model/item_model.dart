// import 'package:json_annotation/json_annotation.dart';

// part 'item_model.g.dart';

// @JsonSerializable()
// class ItemModel {
//   @JsonKey(name: "itemCode")
//   final int itemCode;
//   @JsonKey(name: "barCode")
//   final String barCode;
//   @JsonKey(name: "unit")
//   final String unit;
//   @JsonKey(name: "length")
//   final int length;
//   @JsonKey(name: "width")
//   final int width;
//   @JsonKey(name: "height")
//   final int height;
//   @JsonKey(name: "weight")
//   final double weight;
//   @JsonKey(name: "image")
//   final String image;

//   ItemModel({
//     required this.itemCode,
//     required this.barCode,
//     required this.unit,
//     required this.length,
//     required this.width,
//     required this.height,
//     required this.weight,
//     required this.image,
//   });

//   factory ItemModel.fromJson(Map<String, dynamic> json) =>
//       _$ItemModelFromJson(json);

//   Map<String, dynamic> toJson() => _$ItemModelToJson(this);

//   ItemModel copyWith({
//     int? itemCode,
//     String? barCode,
//     String? unit,
//     int? length,
//     int? width,
//     int? height,
//     double? weight,
//     String? image,
//   }) {
//     return ItemModel(
//       itemCode: itemCode ?? this.itemCode,
//       barCode: barCode ?? this.barCode,
//       unit: unit ?? this.unit,
//       length: length ?? this.length,
//       width: width ?? this.width,
//       height: height ?? this.height,
//       weight: weight ?? this.weight,
//       image: image ?? this.image,
//     );
//   }
// }
