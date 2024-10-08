import 'package:flutter_scanner_app/utils/enum.dart';
import 'package:collection/collection.dart';

class UnitUtils {
  static String convertLength(
      String value, String previousUnit, String currentUnit) {
    if (value.isEmpty) {
      // Nếu không có giá trị đầu vào, trả về giá trị hiện tại không thay đổi.
      return value;
    }

    try {
      final intValue = int.parse(value);
      return UnitUtils.convertUnit(intValue, previousUnit, currentUnit)
          .toString();
    } catch (e) {
      // Xử lý lỗi khi không thể chuyển đổi giá trị
      print('Error converting length: $e');
      return value; // Giữ nguyên giá trị hiện tại
    }
  }

  static String convertWeight(
      String value, String previousUnit, String currentUnit) {
    if (value.isEmpty) {
      // Nếu không có giá trị đầu vào, trả về giá trị hiện tại không thay đổi.
      return value;
    }

    try {
      final intValue = int.parse(value);
      return UnitUtils.convertWeightUnit(intValue, previousUnit, currentUnit)
          .toString();
    } catch (e) {
      // Xử lý lỗi khi không thể chuyển đổi giá trị
      print('Error converting weight: $e');
      return value; // Giữ nguyên giá trị hiện tại
    }
  }

  static int convertUnit(int value, String unitInput, String unitOutput) {
    LengthUnitEnum unitInputEnum =
        LengthUnitEnum.values.firstWhereOrNull((e) => e.name == unitInput) ??
            LengthUnitEnum.mm;
    LengthUnitEnum unitOutputEnum =
        LengthUnitEnum.values.firstWhereOrNull((e) => e.name == unitOutput) ??
            LengthUnitEnum.mm;

    switch (unitInputEnum) {
      case LengthUnitEnum.m:
        return convertMToUnit(value, unitInputEnum, unitOutputEnum);
      case LengthUnitEnum.dm:
        return convertDMToUnit(value, unitInputEnum, unitOutputEnum);
      case LengthUnitEnum.cm:
        return convertCMToUnit(value, unitInputEnum, unitOutputEnum);
      case LengthUnitEnum.mm:
        return convertMMToUnit(value, unitInputEnum, unitOutputEnum);
    }
  }

  static int convertMToUnit(
      int value, LengthUnitEnum unitInput, LengthUnitEnum unitOutput) {
    switch (unitOutput) {
      case LengthUnitEnum.m:
        return value;
      case LengthUnitEnum.dm:
        return value * 10;
      case LengthUnitEnum.cm:
        return value * 100;
      case LengthUnitEnum.mm:
        return value * 1000;
    }
  }

  static int convertDMToUnit(
      int value, LengthUnitEnum unitInput, LengthUnitEnum unitOutput) {
    switch (unitOutput) {
      case LengthUnitEnum.m:
        return (value / 10).round();
      case LengthUnitEnum.dm:
        return value;
      case LengthUnitEnum.cm:
        return value * 10;
      case LengthUnitEnum.mm:
        return value * 100;
    }
  }

  static int convertCMToUnit(
      int value, LengthUnitEnum unitInput, LengthUnitEnum unitOutput) {
    switch (unitOutput) {
      case LengthUnitEnum.m:
        return (value / 100).round();
      case LengthUnitEnum.dm:
        return (value / 10).round();
      case LengthUnitEnum.cm:
        return value;
      case LengthUnitEnum.mm:
        return value * 10;
    }
  }

  static int convertMMToUnit(
      int value, LengthUnitEnum unitInput, LengthUnitEnum unitOutput) {
    switch (unitOutput) {
      case LengthUnitEnum.m:
        return (value / 1000).round();
      case LengthUnitEnum.dm:
        return (value / 100).round();
      case LengthUnitEnum.cm:
        return (value / 10).round();
      case LengthUnitEnum.mm:
        return value;
    }
  }

  // Weight conversion methods
  static int convertWeightUnit(int value, String unitInput, String unitOutput) {
    WeightUnitEnum unitInputEnum =
        WeightUnitEnum.values.firstWhereOrNull((e) => e.name == unitInput) ??
            WeightUnitEnum.g;
    WeightUnitEnum unitOutputEnum =
        WeightUnitEnum.values.firstWhereOrNull((e) => e.name == unitOutput) ??
            WeightUnitEnum.g;

    switch (unitInputEnum) {
      case WeightUnitEnum.kg:
        return convertKgToUnit(value, unitInputEnum, unitOutputEnum);
      case WeightUnitEnum.g:
        return convertGToUnit(value, unitInputEnum, unitOutputEnum);
      case WeightUnitEnum.mg:
        return convertMGToUnit(value, unitInputEnum, unitOutputEnum);
    }
  }

  static int convertKgToUnit(
      int value, WeightUnitEnum unitInput, WeightUnitEnum unitOutput) {
    switch (unitOutput) {
      case WeightUnitEnum.kg:
        return value;
      case WeightUnitEnum.g:
        return value * 1000;
      case WeightUnitEnum.mg:
        return value * 1000 * 1000;
    }
  }

  static int convertGToUnit(
      int value, WeightUnitEnum unitInput, WeightUnitEnum unitOutput) {
    switch (unitOutput) {
      case WeightUnitEnum.kg:
        return (value / 1000).round();
      case WeightUnitEnum.g:
        return value;
      case WeightUnitEnum.mg:
        return value * 1000;
    }
  }

  static int convertMGToUnit(
      int value, WeightUnitEnum unitInput, WeightUnitEnum unitOutput) {
    switch (unitOutput) {
      case WeightUnitEnum.kg:
        return (value / (1000 * 1000)).round();
      case WeightUnitEnum.g:
        return (value / 1000).round();
      case WeightUnitEnum.mg:
        return value;
    }
  }
}
