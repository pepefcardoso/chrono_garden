import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chrono_garden/core/theme/app_theme.dart';
import 'package:chrono_garden/features/game/levels/level_data.dart';
import 'package:chrono_garden/features/game/models/cell_data.dart';
import 'package:chrono_garden/features/game/models/game_state.dart';
import 'package:chrono_garden/features/game/models/grid_data.dart';
import 'package:chrono_garden/features/game/models/inventory.dart';
import 'package:chrono_garden/features/game/models/plant_type.dart';
import 'package:chrono_garden/features/game/notifiers/time_machine_notifier.dart';
import 'package:chrono_garden/features/game/views/game_screen.dart';
import 'package:chrono_garden/features/game/views/widgets/cell_painter.dart';
import 'package:chrono_garden/features/game/views/widgets/game_board.dart';

Widget _wrap(Widget widget, {GameState? initialState}) {
  final List<Override> overrides = <Override>[];

  if (initialState != null) {
    overrides.add(
      timeMachineProvider.overrideWith(
        (
          AutoDisposeStateNotifierProviderRef<
            TimeMachineNotifier,
            TimeMachineState
          >
          ref,
        ) => TimeMachineNotifier(initialState: initialState),
      ),
    );
  }

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: widget),
    ),
  );
}

GameState _state({
  int rows = 3,
  int cols = 3,
  int seedCount = 3,
  List<CellData>? cells,
}) => GameState(
  currentTurn: 0,
  grid: GridData(
    rows: rows,
    cols: cols,
    cells:
        cells ??
        List<CellData>.filled(rows * cols, CellData.empty, growable: false),
  ),
  inventory: Inventory(seedCount: seedCount),
);

void main() {
  group('CellPainter', () {
    test('empty cell produces no goal border', () {
      final BoxDecoration d = CellPainter.decorationFor(CellData.empty);
      expect(d.border, isNull);
      expect(d.color, AppColors.secondary);
    });

    test('obstacle cell produces dark-brown fill', () {
      final BoxDecoration d = CellPainter.decorationFor(CellData.obstacle);
      expect(d.color, const Color(0xFF4E342E));
      expect(d.border, isNull);
    });

    test('goal cell produces cyan border regardless of PlantType', () {
      const List<PlantType> types = PlantType.values;
      for (final PlantType t in types) {
        if (t == PlantType.obstacle) continue;
        final CellData cell = CellData(type: t, isGoalCell: true);
        final BoxDecoration d = CellPainter.decorationFor(cell);
        final Border? border = d.border as Border?;
        expect(
          border?.top.color,
          AppColors.tertiary,
          reason: 'Expected cyan border for goal $t',
        );
        expect(border?.top.width, closeTo(2.5, 0.01));
      }
    });

    test('maturePlant fill is deep green', () {
      final BoxDecoration d = CellPainter.decorationFor(
        const CellData(type: PlantType.maturePlant),
      );
      expect(d.color, const Color(0xFF2E7D32));
    });

    test('isTappable returns true only for empty cells', () {
      expect(CellPainter.isTappable(CellData.empty), isTrue);
      expect(CellPainter.isTappable(CellData.obstacle), isFalse);
      expect(
        CellPainter.isTappable(const CellData(type: PlantType.seed)),
        isFalse,
      );
      expect(
        CellPainter.isTappable(const CellData(type: PlantType.maturePlant)),
        isFalse,
      );
    });

    test('iconMap covers all PlantType values', () {
      for (final PlantType t in PlantType.values) {
        expect(
          CellPainter.iconMap.containsKey(t),
          isTrue,
          reason: 'iconMap missing entry for $t',
        );
      }
    });
  });

  group('GameBoard — cell count', () {
    testWidgets('renders 25 AnimatedContainers for a 5×5 grid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const GameBoard(), initialState: _state(rows: 5, cols: 5)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedContainer), findsNWidgets(25));
    });

    testWidgets('renders 64 AnimatedContainers for an 8×8 grid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const GameBoard(), initialState: _state(rows: 8, cols: 8)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedContainer), findsNWidgets(64));
    });

    testWidgets('renders 9 cells for a 3×3 grid', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const GameBoard(), initialState: _state(rows: 3, cols: 3)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedContainer), findsNWidgets(9));
    });
  });

  group('GameBoard — goal cell visual', () {
    testWidgets('goal cell AnimatedContainer carries cyan border decoration', (
      WidgetTester tester,
    ) async {
      final GameState s = _state(
        rows: 1,
        cols: 1,
        cells: <CellData>[
          const CellData(type: PlantType.empty, isGoalCell: true),
        ],
      );

      await tester.pumpWidget(_wrap(const GameBoard(), initialState: s));
      await tester.pumpAndSettle();

      final AnimatedContainer container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      final BoxDecoration decoration = container.decoration! as BoxDecoration;
      final Border border = decoration.border! as Border;

      expect(border.top.color, AppColors.tertiary);
      expect(border.top.width, closeTo(2.5, 0.01));
    });
  });

  group('GameBoard — tap interaction', () {
    testWidgets('tapping empty cell decrements seedCount', (
      WidgetTester tester,
    ) async {
      final GameState s = _state(rows: 1, cols: 1, seedCount: 3);
      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            timeMachineProvider.overrideWith(
              (
                AutoDisposeStateNotifierProviderRef<
                  TimeMachineNotifier,
                  TimeMachineState
                >
                ref,
              ) => TimeMachineNotifier(initialState: s),
            ),
          ],
          child: Builder(
            builder: (BuildContext ctx) {
              container = ProviderScope.containerOf(ctx);
              return MaterialApp(
                theme: AppTheme.light,
                home: const Scaffold(body: GameBoard()),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final int seedsBefore = container
          .read(timeMachineProvider)
          .current
          .inventory
          .seedCount;

      await tester.tap(find.byType(AnimatedContainer).first);
      await tester.pumpAndSettle();

      final int seedsAfter = container
          .read(timeMachineProvider)
          .current
          .inventory
          .seedCount;

      expect(seedsAfter, lessThan(seedsBefore));
    });

    testWidgets('tapping obstacle cell does not mutate notifier', (
      WidgetTester tester,
    ) async {
      final GameState s = _state(
        rows: 1,
        cols: 1,
        cells: <CellData>[CellData.obstacle],
      );
      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            timeMachineProvider.overrideWith(
              (
                AutoDisposeStateNotifierProviderRef<
                  TimeMachineNotifier,
                  TimeMachineState
                >
                ref,
              ) => TimeMachineNotifier(initialState: s),
            ),
          ],
          child: Builder(
            builder: (BuildContext ctx) {
              container = ProviderScope.containerOf(ctx);
              return MaterialApp(
                theme: AppTheme.light,
                home: const Scaffold(body: GameBoard()),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final TimeMachineState before = container.read(timeMachineProvider);

      await tester.tap(find.byType(AnimatedContainer).first);
      await tester.pumpAndSettle();

      final TimeMachineState after = container.read(timeMachineProvider);
      expect(after.current, equals(before.current));
    });

    testWidgets('tapping mature plant cell is a no-op', (
      WidgetTester tester,
    ) async {
      final GameState s = _state(
        rows: 1,
        cols: 1,
        cells: <CellData>[
          const CellData(type: PlantType.maturePlant, isGoalCell: true),
        ],
      );
      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            timeMachineProvider.overrideWith(
              (
                AutoDisposeStateNotifierProviderRef<
                  TimeMachineNotifier,
                  TimeMachineState
                >
                ref,
              ) => TimeMachineNotifier(initialState: s),
            ),
          ],
          child: Builder(
            builder: (BuildContext ctx) {
              container = ProviderScope.containerOf(ctx);
              return MaterialApp(
                theme: AppTheme.light,
                home: const Scaffold(body: GameBoard()),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final TimeMachineState before = container.read(timeMachineProvider);
      await tester.tap(find.byType(AnimatedContainer).first);
      await tester.pumpAndSettle();

      expect(
        container.read(timeMachineProvider).current,
        equals(before.current),
      );
    });
  });

  group('GameBoard — undo restores state', () {
    testWidgets('planting then undoing restores grid to initial state', (
      WidgetTester tester,
    ) async {
      final GameState initial = _state(rows: 1, cols: 1, seedCount: 3);
      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            timeMachineProvider.overrideWith(
              (
                AutoDisposeStateNotifierProviderRef<
                  TimeMachineNotifier,
                  TimeMachineState
                >
                ref,
              ) => TimeMachineNotifier(initialState: initial),
            ),
          ],
          child: Builder(
            builder: (BuildContext ctx) {
              container = ProviderScope.containerOf(ctx);
              return MaterialApp(
                theme: AppTheme.light,
                home: const Scaffold(body: GameBoard()),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AnimatedContainer).first);
      await tester.pumpAndSettle();

      container.read(timeMachineProvider.notifier).undo();
      await tester.pumpAndSettle();

      final TimeMachineState afterUndo = container.read(timeMachineProvider);
      expect(afterUndo.current.currentTurn, 0);
      expect(afterUndo.current.grid.cells.first.type, PlantType.empty);
    });

    testWidgets(
      'undo all the way back restores exact initial GameState (T-005 regression)',
      (WidgetTester tester) async {
        final GameState initial = _state(rows: 1, cols: 1, seedCount: 3);
        late ProviderContainer container;

        await tester.pumpWidget(
          ProviderScope(
            overrides: <Override>[
              timeMachineProvider.overrideWith(
                (
                  AutoDisposeStateNotifierProviderRef<
                    TimeMachineNotifier,
                    TimeMachineState
                  >
                  ref,
                ) => TimeMachineNotifier(initialState: initial),
              ),
            ],
            child: Builder(
              builder: (BuildContext ctx) {
                container = ProviderScope.containerOf(ctx);
                return MaterialApp(
                  theme: AppTheme.light,
                  home: const Scaffold(body: GameBoard()),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        final TimeMachineNotifier notifier = container.read(
          timeMachineProvider.notifier,
        );

        notifier.plantSeed(row: 0, col: 0);
        for (int i = 0; i < 5; i++) {
          notifier.tick();
        }

        notifier.jumpTo(0);
        await tester.pumpAndSettle();

        final TimeMachineState s = container.read(timeMachineProvider);
        expect(s.currentIndex, 0);
        expect(s.current, equals(initial));
      },
    );
  });

  group('GameScreen — integration', () {
    testWidgets('loads level 0 on mount and displays a GameBoard', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: GameScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GameBoard), findsOneWidget);

      expect(find.byType(AnimatedContainer), findsNWidgets(25));
    });

    testWidgets('top HUD displays turn counter = 0 on load', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: GameScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('undo button is initially disabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: GameScreen())),
      );
      await tester.pumpAndSettle();

      final Finder undoFinder = find.widgetWithText(OutlinedButton, '⏪  Undo');
      expect(undoFinder, findsOneWidget);

      final OutlinedButton undoButton = tester.widget<OutlinedButton>(
        undoFinder,
      );
      expect(undoButton.onPressed, isNull);
    });

    testWidgets(
      'planting a seed enables undo button and advances turn counter',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: GameScreen())),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(AnimatedContainer).first);
        await tester.pumpAndSettle();

        expect(find.text('1'), findsOneWidget);

        final OutlinedButton undoButton = tester.widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, '⏪  Undo'),
        );
        expect(undoButton.onPressed, isNotNull);
      },
    );

    testWidgets(
      'loading level 1 via loadLevelByIndex renders correct cell count',
      (WidgetTester tester) async {
        late ProviderContainer container;

        await tester.pumpWidget(
          ProviderScope(
            child: Builder(
              builder: (BuildContext ctx) {
                container = ProviderScope.containerOf(ctx);
                return const MaterialApp(home: GameScreen());
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        container.read(timeMachineProvider.notifier).loadLevelByIndex(1);
        await tester.pumpAndSettle();

        expect(find.byType(AnimatedContainer), findsNWidgets(25));
        expect(
          container.read(timeMachineProvider).current,
          equals(LevelData.level1),
        );
      },
    );
  });
}
