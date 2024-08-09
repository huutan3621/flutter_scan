enum LengthUnitEnum { m, dm, cm, mm }

enum WeightUnitEnum { kg, g }

enum UnitModel { VIEN, VI, THUNG, HOP }

extension UnitModelExtension on UnitModel {
  // Converts enum to string
  String get name => toString().split('.').last;

  // Converts string to enum
  static UnitModel fromString(String name) {
    return UnitModel.values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Invalid enum value: $name'),
    );
  }
}
