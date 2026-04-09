import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chrono_garden/features/game/models/cell_data.dart';
import 'package:chrono_garden/features/game/models/game_state.dart';
import 'package:chrono_garden/features/game/models/grid_data.dart';
import 'package:chrono_garden/features/game/models/inventory.dart';
import 'package:chrono_garden/features/game/models/plant_type.dart';

part 'time_machine_notifier.freezed.dart';

const int kMaxHistorySize = 20;

final AutoDisposeStateNotifierProvider<TimeMachineNotifier, TimeMachineState>
timeMachineProvider = StateNotifierProvider.autoDispose(
  (Ref ref) => TimeMachineNotifier(
    initialState: TimeMachineNotifier.blankState(rows: 5, cols: 5),
  ),
);

@freezed
class TimeMachineState with _$TimeMachineState {
  const factory TimeMachineState({
    required GameState current,
    required int historyLength,
    required int currentIndex,
    required bool canUndo,
    required bool canRedo,
  }) = _TimeMachineState;
}

class TimeMachineNotifier extends StateNotifier<TimeMachineState> {
  TimeMachineNotifier({required GameState initialState})
    : _history = <GameState>[initialState],
      _currentIndex = 0,
      super(
        TimeMachineState(
          current: initialState,
          historyLength: 1,
          currentIndex: 0,
          canUndo: false,
          canRedo: false,
        ),
      );

  final List<GameState> _history;
  int _currentIndex;

  static GameState blankState({
    required int rows,
    required int cols,
    int seedCount = 3,
  }) {
    return GameState(
      currentTurn: 0,
      grid: GridData(
        rows: rows,
        cols: cols,
        cells: List<CellData>.filled(
          rows * cols,
          CellData.empty,
          growable: false,
        ),
      ),
      inventory: Inventory(seedCount: seedCount),
    );
  }

  GameState tick() {
    final GameState next = _computeNextState(state.current);
    _truncateFuture();
    _history.add(next);

    if (_history.length > kMaxHistorySize) {
      _history.removeAt(0);
    }
    _currentIndex = _history.length - 1;

    _emit();
    return next;
  }

  void undo() {
    if (!state.canUndo) return;
    _currentIndex--;
    _emit();
  }

  void redo() {
    if (!state.canRedo) return;
    _currentIndex++;
    _emit();
  }

  void jumpTo(int index) {
    final int clamped = index.clamp(0, _history.length - 1);
    if (clamped == _currentIndex) return;
    _currentIndex = clamped;
    _emit();
  }

  bool plantSeed({required int row, required int col}) {
    final GameState current = state.current;
    final GridData grid = current.grid;

    if (row < 0 || row >= grid.rows || col < 0 || col >= grid.cols) {
      return false;
    }

    if (current.inventory.seedCount <= 0) return false;

    final int idx = row * grid.cols + col;
    if (grid.cells[idx].type != PlantType.empty) return false;

    final List<CellData> updatedCells = List<CellData>.of(
      grid.cells,
      growable: false,
    );
    updatedCells[idx] = CellData(
      type: PlantType.seed,
      isGoalCell: grid.cells[idx].isGoalCell,
    );

    final GameState seeded = current.copyWith(
      grid: grid.copyWith(cells: updatedCells),
      inventory: current.inventory.copyWith(
        seedCount: current.inventory.seedCount - 1,
      ),
    );

    _truncateFuture();
    _history.add(seeded);
    _currentIndex = _history.length - 1;
    _emit();

    tick();
    return true;
  }

  bool checkVictory() {
    final List<CellData> cells = state.current.grid.cells;
    final Iterable<CellData> goalCells = cells.where(
      (CellData c) => c.isGoalCell,
    );

    if (goalCells.isEmpty) return false;

    return goalCells.every((CellData c) => c.type == PlantType.maturePlant);
  }

  void loadLevel(GameState levelInitialState) {
    _history
      ..clear()
      ..add(levelInitialState);
    _currentIndex = 0;
    _emit();
  }

  GameState _computeNextState(GameState current) {
    final GridData grid = current.grid;
    final List<CellData> newCells = List<CellData>.of(
      grid.cells,
      growable: false,
    );

    for (int i = 0; i < newCells.length; i++) {
      newCells[i] = _evolveCell(newCells[i]);
    }

    return current.copyWith(
      currentTurn: current.currentTurn + 1,
      grid: grid.copyWith(cells: newCells),
    );
  }

  CellData _evolveCell(CellData cell) {
    const int turnsToGrow = 2;

    switch (cell.type) {
      case PlantType.empty:
      case PlantType.obstacle:
      case PlantType.maturePlant:
        return cell.copyWith(turnsInState: cell.turnsInState + 1);

      case PlantType.seed:
        final int next = cell.turnsInState + 1;
        if (next >= turnsToGrow) {
          return CellData(type: PlantType.sprout, isGoalCell: cell.isGoalCell);
        }
        return cell.copyWith(turnsInState: next);

      case PlantType.sprout:
        final int next = cell.turnsInState + 1;
        if (next >= turnsToGrow) {
          return CellData(
            type: PlantType.youngPlant,
            isGoalCell: cell.isGoalCell,
          );
        }
        return cell.copyWith(turnsInState: next);

      case PlantType.youngPlant:
        final int next = cell.turnsInState + 1;
        if (next >= turnsToGrow) {
          return CellData(
            type: PlantType.maturePlant,
            isGoalCell: cell.isGoalCell,
          );
        }
        return cell.copyWith(turnsInState: next);
    }
  }

  void _truncateFuture() {
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }
  }

  void _emit() {
    state = TimeMachineState(
      current: _history[_currentIndex],
      historyLength: _history.length,
      currentIndex: _currentIndex,
      canUndo: _currentIndex > 0,
      canRedo: _currentIndex < _history.length - 1,
    );
  }
}
