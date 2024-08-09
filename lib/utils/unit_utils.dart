import 'package:flutter_scanner_app/model/enum.dart';
import 'package:collection/collection.dart';

class UnitUtils {
  static double convertUnit(double value, String unitInput, String unitOutput) {
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

  static double convertMToUnit(
      double value, LengthUnitEnum unitInput, LengthUnitEnum unitOutput) {
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

  static double convertDMToUnit(
      double value, LengthUnitEnum unitInput, LengthUnitEnum unitOutput) {
    switch (unitOutput) {
      case LengthUnitEnum.m:
        return value / 10;
      case LengthUnitEnum.dm:
        return value;
      case LengthUnitEnum.cm:
        return value * 10;
      case LengthUnitEnum.mm:
        return value * 100;
    }
  }

  static double convertCMToUnit(
      double value, LengthUnitEnum unitInput, LengthUnitEnum unitOutput) {
    switch (unitOutput) {
      case LengthUnitEnum.m:
        return value / 100;
      case LengthUnitEnum.dm:
        return value / 10;
      case LengthUnitEnum.cm:
        return value;
      case LengthUnitEnum.mm:
        return value * 10;
    }
  }

  static double convertMMToUnit(
      double value, LengthUnitEnum unitInput, LengthUnitEnum unitOutput) {
    switch (unitOutput) {
      case LengthUnitEnum.m:
        return value / 1000;
      case LengthUnitEnum.dm:
        return value / 100;
      case LengthUnitEnum.cm:
        return value / 10;
      case LengthUnitEnum.mm:
        return value;
    }
  }

  //weight
  static double convertWeightUnit(
      double value, String unitInput, String unitOutput) {
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
    }
  }

  static double convertKgToUnit(
      double value, WeightUnitEnum unitInput, WeightUnitEnum unitOutput) {
    switch (unitOutput) {
      case WeightUnitEnum.kg:
        return value;
      case WeightUnitEnum.g:
        return value * 1000;
    }
  }

  static double convertGToUnit(
      double value, WeightUnitEnum unitInput, WeightUnitEnum unitOutput) {
    switch (unitOutput) {
      case WeightUnitEnum.kg:
        return value / 1000;
      case WeightUnitEnum.g:
        return value;
    }
  }
}
