import 'package:chrono_garden/features/game/models/cell_data.dart';
import 'package:chrono_garden/features/game/models/game_state.dart';
import 'package:chrono_garden/features/game/models/grid_data.dart';
import 'package:chrono_garden/features/game/models/inventory.dart';
import 'package:chrono_garden/features/game/models/plant_type.dart';

abstract final class LevelData {
  static List<GameState> get all => <GameState>[level0, level1, level2];

  static GameState get level0 {
    const int rows = 5;
    const int cols = 5;
    return GameState(
      currentTurn: 0,
      grid: GridData(
        rows: rows,
        cols: cols,
        cells: _buildCells(rows, cols, <int, CellData>{
          1 * cols + 2: const CellData(type: PlantType.empty, isGoalCell: true),
          3 * cols + 1: CellData.obstacle,
        }),
      ),
      inventory: const Inventory(seedCount: 2),
    );
  }

  static GameState get level1 {
    const int rows = 5;
    const int cols = 5;
    return GameState(
      currentTurn: 0,
      grid: GridData(
        rows: rows,
        cols: cols,
        cells: _buildCells(rows, cols, <int, CellData>{
          1 * cols + 2: const CellData(type: PlantType.empty, isGoalCell: true),
          2 * cols + 1: const CellData(type: PlantType.empty, isGoalCell: true),
          0 * cols + 0: CellData.obstacle,
          0 * cols + 4: CellData.obstacle,
          4 * cols + 0: CellData.obstacle,
          4 * cols + 4: CellData.obstacle,
        }),
      ),
      inventory: const Inventory(seedCount: 3),
    );
  }

  static GameState get level2 {
    const int rows = 8;
    const int cols = 8;

    final Map<int, CellData> overrides = <int, CellData>{
      2 * cols + 1: const CellData(type: PlantType.empty, isGoalCell: true),
      2 * cols + 6: const CellData(type: PlantType.empty, isGoalCell: true),
      5 * cols + 1: const CellData(type: PlantType.empty, isGoalCell: true),
    };

    for (int r = 0; r <= 2; r++) {
      overrides[r * cols + 3] = CellData.obstacle;
      overrides[r * cols + 4] = CellData.obstacle;
    }
    
    for (int r = 5; r <= 7; r++) {
      overrides[r * cols + 3] = CellData.obstacle;
      overrides[r * cols + 4] = CellData.obstacle;
    }

    return GameState(
      currentTurn: 0,
      grid: GridData(
        rows: rows,
        cols: cols,
        cells: _buildCells(rows, cols, overrides),
      ),
      inventory: const Inventory(seedCount: 3),
    );
  }

  static List<CellData> _buildCells(
    int rows,
    int cols,
    Map<int, CellData> overrides,
  ) {
    final List<CellData> cells = List<CellData>.filled(
      rows * cols,
      CellData.empty,
      growable: false,
    );
    overrides.forEach((int idx, CellData cell) {
      cells[idx] = cell;
    });
    return cells;
  }
}
