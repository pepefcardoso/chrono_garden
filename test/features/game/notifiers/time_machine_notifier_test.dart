import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chrono_garden/features/game/models/cell_data.dart';
import 'package:chrono_garden/features/game/models/game_state.dart';
import 'package:chrono_garden/features/game/models/grid_data.dart';
import 'package:chrono_garden/features/game/models/inventory.dart';
import 'package:chrono_garden/features/game/models/plant_type.dart';
import 'package:chrono_garden/features/game/notifiers/time_machine_notifier.dart';

TimeMachineNotifier _notifier({
  int rows = 3,
  int cols = 3,
  int seedCount = 3,
  List<CellData>? cells,
}) {
  final List<CellData> grid =
      cells ?? List<CellData>.filled(rows * cols, CellData.empty);
  return TimeMachineNotifier(
    initialState: GameState(
      currentTurn: 0,
      grid: GridData(rows: rows, cols: cols, cells: grid),
      inventory: Inventory(seedCount: seedCount),
    ),
  );
}

TimeMachineState _read(TimeMachineNotifier n) => n.state;

void main() {
  group('blankState()', () {
    test('produces correct dimensions', () {
      final GameState s = TimeMachineNotifier.blankState(rows: 5, cols: 8);
      expect(s.grid.rows, 5);
      expect(s.grid.cols, 8);
      expect(s.grid.cells.length, 40);
    });

    test('all cells are empty Flyweights', () {
      final GameState s = TimeMachineNotifier.blankState(rows: 2, cols: 2);
      for (final CellData c in s.grid.cells) {
        expect(identical(c, CellData.empty), isTrue);
      }
    });

    test('default seedCount is 3', () {
      final GameState s = TimeMachineNotifier.blankState(rows: 2, cols: 2);
      expect(s.inventory.seedCount, 3);
    });

    test('custom seedCount is respected', () {
      final GameState s = TimeMachineNotifier.blankState(
        rows: 2,
        cols: 2,
        seedCount: 7,
      );
      expect(s.inventory.seedCount, 7);
    });
  });

  group('initial state', () {
    test('currentIndex is 0', () {
      expect(_read(_notifier()).currentIndex, 0);
    });

    test('historyLength is 1', () {
      expect(_read(_notifier()).historyLength, 1);
    });

    test('canUndo is false', () {
      expect(_read(_notifier()).canUndo, isFalse);
    });

    test('canRedo is false', () {
      expect(_read(_notifier()).canRedo, isFalse);
    });

    test('currentTurn is 0', () {
      expect(_read(_notifier()).current.currentTurn, 0);
    });
  });

  group('tick()', () {
    test('increments currentTurn by 1', () {
      final TimeMachineNotifier n = _notifier();
      n.tick();
      expect(_read(n).current.currentTurn, 1);
    });

    test('adds a new entry to history', () {
      final TimeMachineNotifier n = _notifier();
      n.tick();
      expect(_read(n).historyLength, 2);
      expect(_read(n).currentIndex, 1);
    });

    test('canUndo becomes true after tick', () {
      final TimeMachineNotifier n = _notifier();
      n.tick();
      expect(_read(n).canUndo, isTrue);
    });

    test('each tick advances currentTurn monotonically', () {
      final TimeMachineNotifier n = _notifier();
      for (int i = 1; i <= 5; i++) {
        n.tick();
        expect(_read(n).current.currentTurn, i);
      }
    });

    test('history capped at kMaxHistorySize', () {
      final TimeMachineNotifier n = _notifier();
      for (int i = 0; i < kMaxHistorySize + 5; i++) {
        n.tick();
      }
      expect(_read(n).historyLength, kMaxHistorySize);
    });

    test('tick returns the newly created GameState', () {
      final TimeMachineNotifier n = _notifier();
      final GameState returned = n.tick();
      expect(returned, equals(_read(n).current));
    });
  });

  group('undo()', () {
    test('undo moves pointer back by 1', () {
      final TimeMachineNotifier n = _notifier();
      n.tick();
      n.undo();
      expect(_read(n).currentIndex, 0);
      expect(_read(n).current.currentTurn, 0);
    });

    test('undo does not destroy future state', () {
      final TimeMachineNotifier n = _notifier();
      n.tick();
      n.tick();
      n.undo();
      expect(_read(n).historyLength, 3);
      expect(_read(n).canRedo, isTrue);
    });

    test('undo at start is a no-op', () {
      final TimeMachineNotifier n = _notifier();
      n.undo();
      expect(_read(n).currentIndex, 0);
    });

    test('canUndo is false after undoing to start', () {
      final TimeMachineNotifier n = _notifier();
      n.tick();
      n.undo();
      expect(_read(n).canUndo, isFalse);
    });
  });

  group('redo()', () {
    test('redo moves pointer forward by 1', () {
      final TimeMachineNotifier n = _notifier();
      n.tick();
      n.undo();
      n.redo();
      expect(_read(n).currentIndex, 1);
      expect(_read(n).current.currentTurn, 1);
    });

    test('redo at tip is a no-op', () {
      final TimeMachineNotifier n = _notifier();
      n.tick();
      n.redo();
      expect(_read(n).currentIndex, 1);
    });

    test('canRedo is false at tip of history', () {
      final TimeMachineNotifier n = _notifier();
      n.tick();
      expect(_read(n).canRedo, isFalse);
    });

    test('undo → redo restores same state', () {
      final TimeMachineNotifier n = _notifier();
      n.tick();
      final GameState before = _read(n).current;
      n.undo();
      n.redo();
      expect(_read(n).current, equals(before));
    });
  });

  group('timeline divergence', () {
    test('tick after undo truncates redo states', () {
      final TimeMachineNotifier n = _notifier();
      n.tick();
      n.tick();
      n.undo();
      n.tick();
      expect(_read(n).historyLength, 3);
      expect(_read(n).canRedo, isFalse);
    });

    test('diverged state has correct turn count', () {
      final TimeMachineNotifier n = _notifier();
      n.tick();
      n.tick();
      n.undo();
      n.tick();
      expect(_read(n).current.currentTurn, 2);
    });
  });

  group('jumpTo()', () {
    test('jumps to a specific index', () {
      final TimeMachineNotifier n = _notifier();
      n.tick();
      n.tick();
      n.tick();
      n.jumpTo(1);
      expect(_read(n).currentIndex, 1);
      expect(_read(n).current.currentTurn, 1);
    });

    test('jumpTo same index is a no-op (state object unchanged)', () {
      final TimeMachineNotifier n = _notifier();
      n.tick();
      final TimeMachineState before = _read(n);
      n.jumpTo(1);
      expect(identical(_read(n).current, before.current), isTrue);
    });

    test('jumpTo clamps negative index to 0', () {
      final TimeMachineNotifier n = _notifier();
      n.tick();
      n.jumpTo(-5);
      expect(_read(n).currentIndex, 0);
    });

    test('jumpTo clamps over-range index to last', () {
      final TimeMachineNotifier n = _notifier();
      n.tick();
      n.jumpTo(999);
      expect(_read(n).currentIndex, 1);
    });
  });

  group('growth engine', () {
    TimeMachineNotifier _single(CellData cell) =>
        _notifier(rows: 1, cols: 1, cells: <CellData>[cell]);

    test('seed transitions to sprout after 2 ticks', () {
      final TimeMachineNotifier n = _single(
        const CellData(type: PlantType.seed),
      );
      n.tick();
      n.tick();
      expect(_read(n).current.grid.cells.first.type, PlantType.sprout);
    });

    test('sprout transitions to youngPlant after 2 more ticks', () {
      final TimeMachineNotifier n = _single(
        const CellData(type: PlantType.seed),
      );
      for (int i = 0; i < 4; i++) n.tick();
      expect(_read(n).current.grid.cells.first.type, PlantType.youngPlant);
    });

    test('youngPlant transitions to maturePlant after 2 more ticks', () {
      final TimeMachineNotifier n = _single(
        const CellData(type: PlantType.seed),
      );
      for (int i = 0; i < 6; i++) n.tick();
      expect(_read(n).current.grid.cells.first.type, PlantType.maturePlant);
    });

    test('maturePlant does not regress', () {
      final TimeMachineNotifier n = _single(
        const CellData(type: PlantType.maturePlant),
      );
      for (int i = 0; i < 10; i++) n.tick();
      expect(_read(n).current.grid.cells.first.type, PlantType.maturePlant);
    });

    test('obstacle never changes type', () {
      final TimeMachineNotifier n = _single(CellData.obstacle);
      for (int i = 0; i < 5; i++) n.tick();
      expect(_read(n).current.grid.cells.first.type, PlantType.obstacle);
    });

    test('empty cell never changes type', () {
      final TimeMachineNotifier n = _single(CellData.empty);
      for (int i = 0; i < 5; i++) n.tick();
      expect(_read(n).current.grid.cells.first.type, PlantType.empty);
    });

    test('isGoalCell flag is preserved through all growth stages', () {
      final TimeMachineNotifier n = _single(
        const CellData(type: PlantType.seed, isGoalCell: true),
      );
      for (int i = 0; i < 6; i++) n.tick();
      final CellData final_ = _read(n).current.grid.cells.first;
      expect(final_.type, PlantType.maturePlant);
      expect(final_.isGoalCell, isTrue);
    });

    test('determinism: same initial state → same result after N ticks', () {
      final GameState initial = TimeMachineNotifier.blankState(
        rows: 3,
        cols: 3,
      );

      final TimeMachineNotifier n1 = TimeMachineNotifier(initialState: initial);
      final TimeMachineNotifier n2 = TimeMachineNotifier(initialState: initial);

      for (int i = 0; i < 8; i++) {
        n1.tick();
        n2.tick();
      }
      expect(_read(n1).current, equals(_read(n2).current));
    });
  });

  group('plantSeed()', () {
    test('plants a seed at the given cell and decrements seedCount', () {
      final TimeMachineNotifier n = _notifier(rows: 2, cols: 2);
      final bool ok = n.plantSeed(row: 0, col: 1);

      expect(ok, isTrue);
      expect(_read(n).current.currentTurn, 1);
      expect(_read(n).current.inventory.seedCount, lessThan(3));
    });

    test('returns false when no seeds remain', () {
      final TimeMachineNotifier n = _notifier(seedCount: 0);
      expect(n.plantSeed(row: 0, col: 0), isFalse);
    });

    test('returns false when cell is already occupied', () {
      final TimeMachineNotifier n = _notifier(
        rows: 1,
        cols: 1,
        cells: <CellData>[const CellData(type: PlantType.seed)],
      );
      expect(n.plantSeed(row: 0, col: 0), isFalse);
    });

    test('returns false for out-of-bounds coordinates', () {
      final TimeMachineNotifier n = _notifier(rows: 2, cols: 2);
      expect(n.plantSeed(row: 5, col: 5), isFalse);
      expect(n.plantSeed(row: -1, col: 0), isFalse);
    });

    test('planting on goal cell preserves isGoalCell flag', () {
      final TimeMachineNotifier n = _notifier(
        rows: 1,
        cols: 1,
        cells: <CellData>[
          const CellData(type: PlantType.empty, isGoalCell: true),
        ],
      );
      expect(n.plantSeed(row: 0, col: 0), isTrue);
    });
  });

  group('checkVictory()', () {
    test('returns false when no goal cells exist', () {
      final TimeMachineNotifier n = _notifier();
      expect(n.checkVictory(), isFalse);
    });

    test('returns false when goal cell has not yet matured', () {
      final TimeMachineNotifier n = _notifier(
        rows: 1,
        cols: 1,
        cells: <CellData>[
          const CellData(type: PlantType.seed, isGoalCell: true),
        ],
      );
      expect(n.checkVictory(), isFalse);
    });

    test('returns true when all goal cells are maturePlant', () {
      final TimeMachineNotifier n = _notifier(
        rows: 1,
        cols: 1,
        cells: <CellData>[
          const CellData(type: PlantType.maturePlant, isGoalCell: true),
        ],
      );
      expect(n.checkVictory(), isTrue);
    });

    test('returns false when only some goal cells are mature', () {
      final TimeMachineNotifier n = _notifier(
        rows: 1,
        cols: 2,
        cells: <CellData>[
          const CellData(type: PlantType.maturePlant, isGoalCell: true),
          const CellData(type: PlantType.seed, isGoalCell: true),
        ],
      );
      expect(n.checkVictory(), isFalse);
    });

    test('non-goal mature plants do not satisfy victory', () {
      final TimeMachineNotifier n = _notifier(
        rows: 1,
        cols: 2,
        cells: <CellData>[
          const CellData(type: PlantType.seed, isGoalCell: true),
          const CellData(type: PlantType.maturePlant),
        ],
      );
      expect(n.checkVictory(), isFalse);
    });
  });

  group('timeMachineProvider', () {
    test('provider boots with a valid TimeMachineState', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final TimeMachineState s = container.read(timeMachineProvider);
      expect(s.currentIndex, 0);
      expect(s.historyLength, 1);
      expect(s.canUndo, isFalse);
      expect(s.canRedo, isFalse);
    });

    test('provider notifier ticks correctly via container', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(timeMachineProvider.notifier).tick();

      final TimeMachineState s = container.read(timeMachineProvider);
      expect(s.current.currentTurn, 1);
      expect(s.historyLength, 2);
    });
  });
}
