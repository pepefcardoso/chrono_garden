import 'package:freezed_annotation/freezed_annotation.dart';

import 'grid_data.dart';
import 'inventory.dart';

part 'game_state.freezed.dart';
part 'game_state.g.dart';

@freezed
class GameState with _$GameState {
  const factory GameState({
    required int currentTurn,

    required GridData grid,

    required Inventory inventory,
  }) = _GameState;

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);
}
