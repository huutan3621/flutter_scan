import 'package:json_annotation/json_annotation.dart';

part 'location_model.g.dart';

@JsonSerializable()
class LocationModel {
  final String? locationCode;
  final String? scanCode;
  final String? createBy;

  LocationModel({
    this.locationCode,
    this.scanCode,
    this.createBy,
  });

  // A factory constructor for creating an instance from JSON
  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);

  // A method for converting the instance to JSON
  Map<String, dynamic> toJson() => _$LocationModelToJson(this);
}
