import 'package:flutter_test/flutter_test.dart';

import 'package:chrono_garden/features/game/models/cell_data.dart';
import 'package:chrono_garden/features/game/models/game_state.dart';
import 'package:chrono_garden/features/game/models/grid_data.dart';
import 'package:chrono_garden/features/game/models/inventory.dart';
import 'package:chrono_garden/features/game/models/plant_type.dart';

GridData _makeGrid({int rows = 2, int cols = 2}) => GridData(
  rows: rows,
  cols: cols,
  cells: List<CellData>.filled(rows * cols, CellData.empty),
);

const Inventory _defaultInventory = Inventory();

GameState _makeState({int turn = 1}) => GameState(
  currentTurn: turn,
  grid: _makeGrid(),
  inventory: _defaultInventory,
);

void main() {
  group('PlantType', () {
    test('has exactly 6 variants', () {
      expect(PlantType.values.length, 6);
    });

    test('lifecycle order is correct', () {
      expect(PlantType.values, <PlantType>[
        PlantType.empty,
        PlantType.obstacle,
        PlantType.seed,
        PlantType.sprout,
        PlantType.youngPlant,
        PlantType.maturePlant,
      ]);
    });
  });

  group('CellData', () {
    group('Flyweight', () {
      test('CellData.empty is the identical object when accessed twice', () {
        const CellData a = CellData.empty;
        const CellData b = CellData.empty;
        expect(identical(a, b), isTrue);
      });

      test('CellData.obstacle is the identical object when accessed twice', () {
        const CellData a = CellData.obstacle;
        const CellData b = CellData.obstacle;
        expect(identical(a, b), isTrue);
      });

      test('copyWith on Flyweight produces a NEW non-identical instance', () {
        final CellData copied = CellData.empty.copyWith(turnsInState: 1);
        expect(identical(copied, CellData.empty), isFalse);
      });

      test('Flyweight empty has correct defaults', () {
        expect(CellData.empty.type, PlantType.empty);
        expect(CellData.empty.turnsInState, 0);
        expect(CellData.empty.isGoalCell, isFalse);
      });

      test('Flyweight obstacle has correct defaults', () {
        expect(CellData.obstacle.type, PlantType.obstacle);
        expect(CellData.obstacle.turnsInState, 0);
        expect(CellData.obstacle.isGoalCell, isFalse);
      });
    });

    group('equality', () {
      test('two cells with identical fields are equal', () {
        const CellData a = CellData(type: PlantType.seed, turnsInState: 2);
        const CellData b = CellData(type: PlantType.seed, turnsInState: 2);
        expect(a, equals(b));
      });

      test('cells differing in type are not equal', () {
        const CellData a = CellData(type: PlantType.seed);
        const CellData b = CellData(type: PlantType.sprout);
        expect(a, isNot(equals(b)));
      });

      test('cells differing in turnsInState are not equal', () {
        const CellData a = CellData(type: PlantType.seed, turnsInState: 1);
        const CellData b = CellData(type: PlantType.seed, turnsInState: 2);
        expect(a, isNot(equals(b)));
      });

      test('cells differing in isGoalCell are not equal', () {
        const CellData a = CellData(type: PlantType.empty);
        const CellData b = CellData(type: PlantType.empty, isGoalCell: true);
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('copyWith changes only the specified field', () {
        const CellData original = CellData(
          type: PlantType.seed,
          turnsInState: 1,
        );
        final CellData updated = original.copyWith(turnsInState: 3);

        expect(updated.type, PlantType.seed);
        expect(updated.turnsInState, 3);
        expect(updated.isGoalCell, isFalse);
        expect(original, isNot(equals(updated)));
      });
    });

    group('JSON', () {
      test('round-trip preserves all fields', () {
        const CellData original = CellData(
          type: PlantType.maturePlant,
          turnsInState: 4,
          isGoalCell: true,
        );
        final CellData restored = CellData.fromJson(original.toJson());
        expect(restored, equals(original));
      });

      test('default fields are omitted from JSON (include_if_null: false)', () {
        final Map<String, dynamic> json = CellData.empty.toJson();
        expect(json.containsKey('turnsInState'), isFalse);
        expect(json.containsKey('isGoalCell'), isFalse);
      });

      test('enum is serialised by name', () {
        const CellData cell = CellData(type: PlantType.youngPlant);
        expect(cell.toJson()['type'], 'youngPlant');
      });
    });
  });

  group('GridData', () {
    test('flat list has rows * cols length', () {
      final GridData grid = _makeGrid(rows: 3, cols: 4);
      expect(grid.cells.length, 12);
    });

    test('row-major indexing formula is correct', () {
      const int rows = 2;
      const int cols = 3;
      final List<CellData> cells = List<CellData>.filled(
        rows * cols,
        CellData.empty,
      );
      const CellData seedCell = CellData(type: PlantType.seed);
      cells[1 * cols + 2] = seedCell;

      final GridData grid = GridData(rows: rows, cols: cols, cells: cells);
      expect(grid.cells[1 * cols + 2].type, PlantType.seed);
    });

    group('equality', () {
      test('two identical grids are equal', () {
        final GridData a = _makeGrid();
        final GridData b = _makeGrid();
        expect(a, equals(b));
      });

      test('grids with different cells are not equal', () {
        final GridData a = _makeGrid();
        final List<CellData> altCells = List<CellData>.filled(
          4,
          CellData.obstacle,
        );
        final GridData b = GridData(rows: 2, cols: 2, cells: altCells);
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('copyWith changes only the specified field', () {
        final GridData original = _makeGrid(rows: 2, cols: 2);
        final GridData updated = original.copyWith(rows: 5);
        expect(updated.rows, 5);
        expect(updated.cols, original.cols);
        expect(updated.cells, original.cells);
      });
    });

    group('JSON', () {
      test('round-trip preserves structure', () {
        final GridData original = _makeGrid(rows: 2, cols: 2);
        final GridData restored = GridData.fromJson(original.toJson());
        expect(restored, equals(original));
      });
    });
  });

  group('Inventory', () {
    test('default seedCount is 3', () {
      expect(_defaultInventory.seedCount, 3);
    });

    test('copyWith changes only seedCount', () {
      final Inventory updated = _defaultInventory.copyWith(seedCount: 0);
      expect(updated.seedCount, 0);
    });

    group('JSON', () {
      test('round-trip preserves seedCount', () {
        const Inventory original = Inventory(seedCount: 5);
        final Inventory restored = Inventory.fromJson(original.toJson());
        expect(restored.seedCount, 5);
      });

      test('default seedCount is omitted from JSON', () {
        final Map<String, dynamic> json = _defaultInventory.toJson();
        expect(json.containsKey('seedCount'), isFalse);
      });
    });
  });

  group('GameState', () {
    group('equality', () {
      test('two identical GameState instances are equal', () {
        final GameState s1 = _makeState();
        final GameState s2 = _makeState();
        expect(s1, equals(s2));
      });

      test('states differing in currentTurn are not equal', () {
        final GameState s1 = _makeState(turn: 1);
        final GameState s2 = _makeState(turn: 2);
        expect(s1, isNot(equals(s2)));
      });
    });

    group('copyWith', () {
      test('copyWith produces new instance with only changed field', () {
        final GameState s1 = _makeState(turn: 1);
        final GameState s2 = s1.copyWith(currentTurn: 2);

        expect(s2.currentTurn, 2);
        expect(s2.grid, s1.grid);
        expect(s2.inventory, s1.inventory);
        expect(s1, isNot(equals(s2)));
      });

      test('copyWith does not mutate original', () {
        final GameState original = _makeState(turn: 1);
        final GameState _ = original.copyWith(currentTurn: 99);
        expect(original.currentTurn, 1);
      });

      test('chaining copyWith accumulates changes correctly', () {
        final GameState base = _makeState(turn: 1);
        final GameState step1 = base.copyWith(currentTurn: 2);
        final GameState step2 = step1.copyWith(
          inventory: const Inventory(seedCount: 0),
        );

        expect(step2.currentTurn, 2);
        expect(step2.inventory.seedCount, 0);
        expect(step2.grid, base.grid);
      });
    });

    group('JSON', () {
      test('round-trip preserves all nested fields', () {
        const GameState original = GameState(
          currentTurn: 3,
          grid: GridData(
            rows: 1,
            cols: 2,
            cells: <CellData>[
              CellData(type: PlantType.seed, turnsInState: 1),
              CellData(type: PlantType.maturePlant, isGoalCell: true),
            ],
          ),
          inventory: Inventory(seedCount: 1),
        );

        final GameState restored = GameState.fromJson(original.toJson());
        expect(restored, equals(original));
      });

      test('null values are absent from JSON output', () {
        final GameState state = _makeState();
        final Map<String, dynamic> json = state.toJson();
        final bool hasNullValue = json.values.any((Object? v) => v == null);
        expect(hasNullValue, isFalse);
      });

      test('currentTurn is present in JSON', () {
        final GameState state = _makeState(turn: 7);
        expect(state.toJson()['currentTurn'], 7);
      });
    });
  });
}
