import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chrono_garden/features/game/levels/level_data.dart';
import 'package:chrono_garden/features/game/models/cell_data.dart';
import 'package:chrono_garden/features/game/models/game_state.dart';
import 'package:chrono_garden/features/game/models/plant_type.dart';
import 'package:chrono_garden/features/game/notifiers/time_machine_notifier.dart';

void main() {
  group('LevelData', () {
    group('registry', () {
      test('all returns exactly 3 levels', () {
        expect(LevelData.all.length, 3);
      });

      test('all[0] is identical to level0', () {
        expect(LevelData.all[0], equals(LevelData.level0));
      });

      test('all[1] is identical to level1', () {
        expect(LevelData.all[1], equals(LevelData.level1));
      });

      test('all[2] is identical to level2', () {
        expect(LevelData.all[2], equals(LevelData.level2));
      });

      test(
        'each call to all returns a fresh list (not a shared reference)',
        () {
          final List<GameState> a = LevelData.all;
          final List<GameState> b = LevelData.all;
          expect(identical(a, b), isFalse);
        },
      );
    });

    group('grid dimensions', () {
      test('level0 is 5×5 with 25 cells', () {
        final GameState s = LevelData.level0;
        expect(s.grid.rows, 5);
        expect(s.grid.cols, 5);
        expect(s.grid.cells.length, 25);
      });

      test('level1 is 5×5 with 25 cells', () {
        final GameState s = LevelData.level1;
        expect(s.grid.rows, 5);
        expect(s.grid.cols, 5);
        expect(s.grid.cells.length, 25);
      });

      test('level2 is 8×8 with 64 cells', () {
        final GameState s = LevelData.level2;
        expect(s.grid.rows, 8);
        expect(s.grid.cols, 8);
        expect(s.grid.cells.length, 64);
      });
    });

    group('initial turn', () {
      test('every level starts at currentTurn == 0', () {
        for (final GameState level in LevelData.all) {
          expect(level.currentTurn, 0);
        }
      });
    });

    group('clean initial state', () {
      test('no level has a seed or grown plant in its initial grid', () {
        const Set<PlantType> forbiddenTypes = <PlantType>{
          PlantType.seed,
          PlantType.sprout,
          PlantType.youngPlant,
          PlantType.maturePlant,
        };
        for (final GameState level in LevelData.all) {
          for (final CellData cell in level.grid.cells) {
            expect(
              forbiddenTypes.contains(cell.type),
              isFalse,
              reason:
                  'Level has a pre-planted/grown cell: ${cell.type}. '
                  'All cells must start as empty or obstacle.',
            );
          }
        }
      });
    });

    group('goal cells', () {
      test('every level has at least one goal cell', () {
        for (final GameState level in LevelData.all) {
          final bool hasGoal = level.grid.cells.any(
            (CellData c) => c.isGoalCell,
          );
          expect(
            hasGoal,
            isTrue,
            reason:
                'Level has no goal cell — checkVictory() would always fail.',
          );
        }
      });

      test('level0 has exactly 1 goal cell', () {
        final int count = LevelData.level0.grid.cells
            .where((CellData c) => c.isGoalCell)
            .length;
        expect(count, 1);
      });

      test('level1 has exactly 2 goal cells', () {
        final int count = LevelData.level1.grid.cells
            .where((CellData c) => c.isGoalCell)
            .length;
        expect(count, 2);
      });

      test('level2 has exactly 3 goal cells', () {
        final int count = LevelData.level2.grid.cells
            .where((CellData c) => c.isGoalCell)
            .length;
        expect(count, 3);
      });

      test('level0 goal cell is at index (1,2) = index 7', () {
        const int cols = 5;
        final CellData cell = LevelData.level0.grid.cells[1 * cols + 2];
        expect(cell.isGoalCell, isTrue);
        expect(cell.type, PlantType.empty);
      });

      test('level1 goal cell at (1,2) is marked correctly', () {
        const int cols = 5;
        final CellData cell = LevelData.level1.grid.cells[1 * cols + 2];
        expect(cell.isGoalCell, isTrue);
      });

      test('level1 goal cell at (2,1) is marked correctly', () {
        const int cols = 5;
        final CellData cell = LevelData.level1.grid.cells[2 * cols + 1];
        expect(cell.isGoalCell, isTrue);
      });

      test('level2 goal cell at (2,1) is marked correctly', () {
        const int cols = 8;
        final CellData cell = LevelData.level2.grid.cells[2 * cols + 1];
        expect(cell.isGoalCell, isTrue);
      });

      test('level2 goal cell at (2,6) is marked correctly', () {
        const int cols = 8;
        final CellData cell = LevelData.level2.grid.cells[2 * cols + 6];
        expect(cell.isGoalCell, isTrue);
      });

      test('level2 goal cell at (5,1) is marked correctly', () {
        const int cols = 8;
        final CellData cell = LevelData.level2.grid.cells[5 * cols + 1];
        expect(cell.isGoalCell, isTrue);
      });
    });

    group('obstacles', () {
      test('level0 has exactly 1 obstacle at (3,1)', () {
        const int cols = 5;
        final List<CellData> cells = LevelData.level0.grid.cells;
        final int obstacleCount = cells
            .where((CellData c) => c.type == PlantType.obstacle)
            .length;
        expect(obstacleCount, 1);
        expect(cells[3 * cols + 1].type, PlantType.obstacle);
      });

      test('level1 has exactly 4 obstacles at the four corners', () {
        const int cols = 5;
        final List<CellData> cells = LevelData.level1.grid.cells;
        final int obstacleCount = cells
            .where((CellData c) => c.type == PlantType.obstacle)
            .length;
        expect(obstacleCount, 4);
        expect(cells[0 * cols + 0].type, PlantType.obstacle);
        expect(cells[0 * cols + 4].type, PlantType.obstacle);
        expect(cells[4 * cols + 0].type, PlantType.obstacle);
        expect(cells[4 * cols + 4].type, PlantType.obstacle);
      });

      test('level2 obstacle wall: cols 3 & 4, rows 0-2 are obstacles', () {
        const int cols = 8;
        final List<CellData> cells = LevelData.level2.grid.cells;
        for (int r = 0; r <= 2; r++) {
          expect(
            cells[r * cols + 3].type,
            PlantType.obstacle,
            reason: 'Expected obstacle at ($r, 3)',
          );
          expect(
            cells[r * cols + 4].type,
            PlantType.obstacle,
            reason: 'Expected obstacle at ($r, 4)',
          );
        }
      });

      test('level2 obstacle wall: cols 3 & 4, rows 5-7 are obstacles', () {
        const int cols = 8;
        final List<CellData> cells = LevelData.level2.grid.cells;
        for (int r = 5; r <= 7; r++) {
          expect(
            cells[r * cols + 3].type,
            PlantType.obstacle,
            reason: 'Expected obstacle at ($r, 3)',
          );
          expect(
            cells[r * cols + 4].type,
            PlantType.obstacle,
            reason: 'Expected obstacle at ($r, 4)',
          );
        }
      });

      test('level2 corridor rows 3-4 have no obstacles in cols 3 & 4', () {
        const int cols = 8;
        final List<CellData> cells = LevelData.level2.grid.cells;
        for (int r = 3; r <= 4; r++) {
          expect(
            cells[r * cols + 3].type,
            isNot(PlantType.obstacle),
            reason: 'Corridor cell ($r, 3) should not be an obstacle',
          );
          expect(
            cells[r * cols + 4].type,
            isNot(PlantType.obstacle),
            reason: 'Corridor cell ($r, 4) should not be an obstacle',
          );
        }
      });
    });

    group('inventory', () {
      test('level0 seedCount is 2', () {
        expect(LevelData.level0.inventory.seedCount, 2);
      });

      test('level1 seedCount is 3', () {
        expect(LevelData.level1.inventory.seedCount, 3);
      });

      test('level2 seedCount is 3', () {
        expect(LevelData.level2.inventory.seedCount, 3);
      });
    });

    group('checkVictory regression', () {
      test('checkVictory returns false for all level initial states', () {
        for (int i = 0; i < LevelData.all.length; i++) {
          final TimeMachineNotifier notifier = TimeMachineNotifier(
            initialState: LevelData.all[i],
          );
          expect(
            notifier.checkVictory(),
            isFalse,
            reason: 'Level $i should not start in a victory state.',
          );
        }
      });
    });

    group('integration with TimeMachineNotifier', () {
      test('loadLevel(level0) resets notifier history to 1 entry', () {
        final TimeMachineNotifier notifier = TimeMachineNotifier(
          initialState: TimeMachineNotifier.blankState(rows: 3, cols: 3),
        );
        
        notifier.tick();
        notifier.tick();

        notifier.loadLevel(LevelData.level0);

        expect(notifier.state.historyLength, 1);
        expect(notifier.state.currentIndex, 0);
        expect(notifier.state.canUndo, isFalse);
        expect(notifier.state.canRedo, isFalse);
        expect(notifier.state.current, equals(LevelData.level0));
      });

      test('loadLevelByIndex(0) loads level0 correctly', () {
        final TimeMachineNotifier notifier = TimeMachineNotifier(
          initialState: TimeMachineNotifier.blankState(rows: 3, cols: 3),
        );
        notifier.loadLevelByIndex(0);
        expect(notifier.state.current, equals(LevelData.level0));
      });

      test('loadLevelByIndex(1) loads level1 correctly', () {
        final TimeMachineNotifier notifier = TimeMachineNotifier(
          initialState: TimeMachineNotifier.blankState(rows: 3, cols: 3),
        );
        notifier.loadLevelByIndex(1);
        expect(notifier.state.current, equals(LevelData.level1));
      });

      test('loadLevelByIndex(2) loads level2 correctly', () {
        final TimeMachineNotifier notifier = TimeMachineNotifier(
          initialState: TimeMachineNotifier.blankState(rows: 3, cols: 3),
        );
        notifier.loadLevelByIndex(2);
        expect(notifier.state.current, equals(LevelData.level2));
      });

      test('after loadLevel(level0), tick advances turn and engine runs', () {
        final TimeMachineNotifier notifier = TimeMachineNotifier(
          initialState: TimeMachineNotifier.blankState(rows: 3, cols: 3),
        );
        notifier.loadLevel(LevelData.level0);
        notifier.tick();
        expect(notifier.state.current.currentTurn, 1);
        expect(notifier.state.historyLength, 2);
      });

      test('timeMachineProvider loads level0 via loadLevelByIndex', () {
        final ProviderContainer container = ProviderContainer();
        addTearDown(container.dispose);

        container.read(timeMachineProvider.notifier).loadLevelByIndex(0);

        final TimeMachineState s = container.read(timeMachineProvider);
        expect(s.current, equals(LevelData.level0));
        expect(s.historyLength, 1);
      });
    });
  });
}
