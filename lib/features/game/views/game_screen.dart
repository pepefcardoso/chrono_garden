import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chrono_garden/core/theme/app_theme.dart';
import 'package:chrono_garden/features/game/notifiers/time_machine_notifier.dart';
import 'package:chrono_garden/features/game/views/widgets/game_board.dart';

class GameScreen extends HookConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TimeMachineState tmState = ref.watch(timeMachineProvider);

    useEffect(() {
      ref.read(timeMachineProvider.notifier).loadLevelByIndex(0);
      return null;
    }, const <Object?>[]);

    return Scaffold(
      backgroundColor: AppColors.neutral,
      appBar: AppBar(
        title: const Text('Chrono Garden'),
        backgroundColor: AppColors.neutral,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _TopHud(
              currentTurn: tmState.current.currentTurn,
              seedCount: tmState.current.inventory.seedCount,
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: const GameBoard(),
              ),
            ),

            _BottomHud(
              canUndo: tmState.canUndo,
              canRedo: tmState.canRedo,
              onUndo: () => ref.read(timeMachineProvider.notifier).undo(),
              onRedo: () => ref.read(timeMachineProvider.notifier).redo(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopHud extends StatelessWidget {
  const _TopHud({required this.currentTurn, required this.seedCount});

  final int currentTurn;
  final int seedCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('TURN', style: AppTextStyles.labelSmall),
              Text('$currentTurn', style: AppTextStyles.hugeCounter),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text('SEEDS', style: AppTextStyles.labelSmall),
              Row(
                children: <Widget>[
                  Text('$seedCount', style: AppTextStyles.hudLabel),
                  const SizedBox(width: 4),
                  const Text('🌱', style: TextStyle(fontSize: 18)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomHud extends StatelessWidget {
  const _BottomHud({
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
  });

  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _HudButton(label: '⏪  Undo', enabled: canUndo, onPressed: onUndo),
          _HudButton(label: '⏩  Redo', enabled: canRedo, onPressed: onRedo),
        ],
      ),
    );
  }
}

class _HudButton extends StatelessWidget {
  const _HudButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.tertiary,
        disabledForegroundColor: AppColors.tertiarySubtle,
        side: BorderSide(
          color: enabled ? AppColors.tertiary : AppColors.tertiarySubtle,
          width: 2,
        ),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        textStyle: AppTextStyles.buttonLabel,
      ),
      child: Text(label),
    );
  }
}
