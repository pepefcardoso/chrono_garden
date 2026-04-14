import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chrono_garden/core/theme/app_theme.dart';
import 'package:chrono_garden/features/game/models/cell_data.dart';
import 'package:chrono_garden/features/game/models/game_state.dart';
import 'package:chrono_garden/features/game/models/grid_data.dart';
import 'package:chrono_garden/features/game/models/inventory.dart';
import 'package:chrono_garden/features/game/notifiers/time_machine_notifier.dart';
import 'package:chrono_garden/features/game/views/game_screen.dart';

ProviderContainer _makeContainer({GameState? initialState}) {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      if (initialState != null)
        timeMachineProvider.overrideWith(
          (
            AutoDisposeStateNotifierProviderRef<
              TimeMachineNotifier,
              TimeMachineState
            >
            ref,
          ) => TimeMachineNotifier(initialState: initialState),
        ),
    ],
  );
  return container;
}

Widget _wrapScreen({GameState? initialState}) {
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
      home: const GameScreen(),
    ),
  );
}

GameState _state({int rows = 3, int cols = 3, int seedCount = 3}) => GameState(
  currentTurn: 0,
  grid: GridData(
    rows: rows,
    cols: cols,
    cells: List<CellData>.filled(rows * cols, CellData.empty, growable: false),
  ),
  inventory: Inventory(seedCount: seedCount),
);

void main() {
  group('TimeMachineState — Slider data contract', () {
    test('maxIndex for slider equals historyLength - 1', () {
      final ProviderContainer container = _makeContainer(
        initialState: _state(),
      );
      addTearDown(container.dispose);

      final TimeMachineNotifier notifier =
          container.read(timeMachineProvider.notifier);

      notifier.tick();
      notifier.tick();

      final TimeMachineState s = container.read(timeMachineProvider);
      expect(s.historyLength - 1, 2);
    });

    test('jumpTo(0) after ticks restores exact initial state', () {
      final GameState initial = _state();
      final ProviderContainer container = _makeContainer(
        initialState: initial,
      );
      addTearDown(container.dispose);

      final TimeMachineNotifier notifier =
          container.read(timeMachineProvider.notifier);

      notifier.tick();
      notifier.tick();
      notifier.tick();
      notifier.jumpTo(0);

      final TimeMachineState s = container.read(timeMachineProvider);
      expect(s.current, equals(initial));
      expect(s.currentIndex, 0);
    });

    test('jumpTo beyond maxIndex clamps to last entry', () {
      final ProviderContainer container = _makeContainer(
        initialState: _state(),
      );
      addTearDown(container.dispose);

      final TimeMachineNotifier notifier =
          container.read(timeMachineProvider.notifier);

      notifier.tick();
      notifier.jumpTo(999);

      expect(container.read(timeMachineProvider).currentIndex, 1);
    });

    test('jumpTo with historyLength == 1 is a no-op (clamp to 0)', () {
      final ProviderContainer container = _makeContainer(
        initialState: _state(),
      );
      addTearDown(container.dispose);

      container.read(timeMachineProvider.notifier).jumpTo(5);

      expect(container.read(timeMachineProvider).currentIndex, 0);
    });
  });

  group('Top HUD', () {
    testWidgets('displays TURN label and zero counter on initial load', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrapScreen(initialState: _state()));
      await tester.pumpAndSettle();

      expect(find.text('TURN'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('displays SEEDS label', (WidgetTester tester) async {
      await tester.pumpWidget(_wrapScreen(initialState: _state(seedCount: 5)));
      await tester.pumpAndSettle();

      expect(find.text('SEEDS'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('turn counter updates after ticking the notifier', (
      WidgetTester tester,
    ) async {
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
              ) => TimeMachineNotifier(initialState: _state()),
            ),
          ],
          child: Builder(
            builder: (BuildContext ctx) {
              container = ProviderScope.containerOf(ctx);
              return MaterialApp(
                theme: AppTheme.light,
                home: const GameScreen(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      container.read(timeMachineProvider.notifier).tick();
      container.read(timeMachineProvider.notifier).tick();
      container.read(timeMachineProvider.notifier).tick();
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
    });
  });

  group('Bottom HUD — Slider', () {
    testWidgets(
      'Slider is disabled (onChanged null) when historyLength == 1',
      (WidgetTester tester) async {
        await tester.pumpWidget(_wrapScreen(initialState: _state()));
        await tester.pumpAndSettle();

        final Slider slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.onChanged, isNull);
      },
    );

    testWidgets(
      'Slider is enabled and value == 0 after first tick (historyLength == 2, index == 1)',
      (WidgetTester tester) async {
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
                ) => TimeMachineNotifier(initialState: _state()),
              ),
            ],
            child: Builder(
              builder: (BuildContext ctx) {
                container = ProviderScope.containerOf(ctx);
                return MaterialApp(
                  theme: AppTheme.light,
                  home: const GameScreen(),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        container.read(timeMachineProvider.notifier).tick();
        await tester.pumpAndSettle();

        final Slider slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.onChanged, isNotNull);
        expect(slider.value, 1.0);
        expect(slider.max, 1.0);
      },
    );

    testWidgets('Slider value reflects currentIndex after jumpTo', (
      WidgetTester tester,
    ) async {
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
              ) => TimeMachineNotifier(initialState: _state()),
            ),
          ],
          child: Builder(
            builder: (BuildContext ctx) {
              container = ProviderScope.containerOf(ctx);
              return MaterialApp(
                theme: AppTheme.light,
                home: const GameScreen(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      container.read(timeMachineProvider.notifier).tick();
      container.read(timeMachineProvider.notifier).tick();
      container.read(timeMachineProvider.notifier).tick();
      await tester.pumpAndSettle();

      container.read(timeMachineProvider.notifier).jumpTo(1);
      await tester.pumpAndSettle();

      final Slider slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 1.0);
    });

    testWidgets('Slider value reflects 0 after undo back to start', (
      WidgetTester tester,
    ) async {
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
              ) => TimeMachineNotifier(initialState: _state()),
            ),
          ],
          child: Builder(
            builder: (BuildContext ctx) {
              container = ProviderScope.containerOf(ctx);
              return MaterialApp(
                theme: AppTheme.light,
                home: const GameScreen(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      container.read(timeMachineProvider.notifier).tick();
      await tester.pumpAndSettle();

      container.read(timeMachineProvider.notifier).undo();
      await tester.pumpAndSettle();

      final Slider slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 0.0);
    });

    testWidgets('Slider shows correct context labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrapScreen(initialState: _state()));
      await tester.pumpAndSettle();

      expect(find.text('PASSADO'), findsOneWidget);
      expect(find.text('AGORA'), findsOneWidget);
      expect(find.textContaining('TURNO'), findsOneWidget);
    });

    testWidgets(
      'Slider divisions equals maxIndex when historyLength > 1',
      (WidgetTester tester) async {
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
                ) => TimeMachineNotifier(initialState: _state()),
              ),
            ],
            child: Builder(
              builder: (BuildContext ctx) {
                container = ProviderScope.containerOf(ctx);
                return MaterialApp(
                  theme: AppTheme.light,
                  home: const GameScreen(),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        container.read(timeMachineProvider.notifier).tick();
        container.read(timeMachineProvider.notifier).tick();
        await tester.pumpAndSettle();

        final Slider slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.divisions, 2);
      },
    );
  });

  group('Bottom HUD — Undo / Redo buttons', () {
    testWidgets('Undo button is initially disabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrapScreen(initialState: _state()));
      await tester.pumpAndSettle();

      final OutlinedButton undoBtn = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, '⏪  Undo'),
      );
      expect(undoBtn.onPressed, isNull);
    });

    testWidgets('Redo button is initially disabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrapScreen(initialState: _state()));
      await tester.pumpAndSettle();

      final OutlinedButton redoBtn = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, '⏩  Redo'),
      );
      expect(redoBtn.onPressed, isNull);
    });

    testWidgets('Undo button enables after a tick and pressing undo reverts', (
      WidgetTester tester,
    ) async {
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
              ) => TimeMachineNotifier(initialState: _state()),
            ),
          ],
          child: Builder(
            builder: (BuildContext ctx) {
              container = ProviderScope.containerOf(ctx);
              return MaterialApp(
                theme: AppTheme.light,
                home: const GameScreen(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      container.read(timeMachineProvider.notifier).tick();
      await tester.pumpAndSettle();

      final OutlinedButton undoBtn = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, '⏪  Undo'),
      );
      expect(undoBtn.onPressed, isNotNull);

      await tester.tap(find.widgetWithText(OutlinedButton, '⏪  Undo'));
      await tester.pumpAndSettle();

      expect(container.read(timeMachineProvider).currentIndex, 0);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('Redo button enables after undo', (
      WidgetTester tester,
    ) async {
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
              ) => TimeMachineNotifier(initialState: _state()),
            ),
          ],
          child: Builder(
            builder: (BuildContext ctx) {
              container = ProviderScope.containerOf(ctx);
              return MaterialApp(
                theme: AppTheme.light,
                home: const GameScreen(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      container.read(timeMachineProvider.notifier).tick();
      container.read(timeMachineProvider.notifier).undo();
      await tester.pumpAndSettle();

      final OutlinedButton redoBtn = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, '⏩  Redo'),
      );
      expect(redoBtn.onPressed, isNotNull);
    });
  });

  group('GameScreen — no constructor params on HUDs (architecture contract)', () {
    testWidgets('GameScreen renders without requiring external state params', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: GameScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TURN'), findsOneWidget);
      expect(find.text('SEEDS'), findsOneWidget);
      expect(find.text('PASSADO'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });
  });
}