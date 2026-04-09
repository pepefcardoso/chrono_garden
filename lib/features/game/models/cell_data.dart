import 'package:freezed_annotation/freezed_annotation.dart';

import 'plant_type.dart';

part 'cell_data.freezed.dart';
part 'cell_data.g.dart';

@freezed
class CellData with _$CellData {
  const factory CellData({
    required PlantType type,

    @Default(0) int turnsInState,

    @Default(false) bool isGoalCell,
  }) = _CellData;

  static const CellData empty = CellData(type: PlantType.empty);

  static const CellData obstacle = CellData(type: PlantType.obstacle);

  factory CellData.fromJson(Map<String, dynamic> json) =>
      _$CellDataFromJson(json);
}