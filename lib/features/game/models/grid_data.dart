import 'package:freezed_annotation/freezed_annotation.dart';

import 'cell_data.dart';

part 'grid_data.freezed.dart';
part 'grid_data.g.dart';

@freezed
class GridData with _$GridData {
  const factory GridData({
    required int rows,
    required int cols,

    required List<CellData> cells,
  }) = _GridData;

  factory GridData.fromJson(Map<String, dynamic> json) =>
      _$GridDataFromJson(json);
}
