import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chrono_garden/core/theme/app_theme.dart';
import 'package:chrono_garden/features/game/notifiers/time_machine_notifier.dart';
import 'package:chrono_garden/features/game/views/widgets/game_board.dart';

class GameScreen extends HookConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      ref.read(timeMachineProvider.notifier).loadLevelByIndex(0);
      return null;
    }, const <Object?>[]);

    return const Scaffold(
      backgroundColor: AppColors.neutral,
      appBar: _GameAppBar(),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _TopHud(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GameBoard(),
              ),
            ),
            _BottomHud(),
          ],
        ),
      ),
    );
  }
}

class _GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _GameAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Chrono Garden'),
      backgroundColor: AppColors.neutral,
      elevation: 0,
    );
  }
}

class _TopHud extends ConsumerWidget {
  const _TopHud();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int turn = ref.watch(
      timeMachineProvider.select((TimeMachineState s) => s.current.currentTurn),
    );
    final int seeds = ref.watch(
      timeMachineProvider.select(
        (TimeMachineState s) => s.current.inventory.seedCount,
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('TURN', style: AppTextStyles.labelSmall),
              Text('$turn', style: AppTextStyles.hugeCounter),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('SEEDS', style: AppTextStyles.labelSmall),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('$seeds', style: AppTextStyles.hudLabel),
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

class _BottomHud extends ConsumerWidget {
  const _BottomHud();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentIndex = ref.watch(
      timeMachineProvider.select((TimeMachineState s) => s.currentIndex),
    );
    final int historyLength = ref.watch(
      timeMachineProvider.select((TimeMachineState s) => s.historyLength),
    );
    final bool canUndo = ref.watch(
      timeMachineProvider.select((TimeMachineState s) => s.canUndo),
    );
    final bool canRedo = ref.watch(
      timeMachineProvider.select((TimeMachineState s) => s.canRedo),
    );
    final int currentTurn = ref.watch(
      timeMachineProvider.select((TimeMachineState s) => s.current.currentTurn),
    );

    final int maxIndex = (historyLength - 1).clamp(0, kMaxHistorySize);
    final bool sliderActive = maxIndex > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('PASSADO', style: AppTextStyles.labelSmall),
                Text(
                  'TURNO $currentTurn',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.tertiary,
                  ),
                ),
                Text('AGORA', style: AppTextStyles.labelSmall),
              ],
            ),
          ),

          Semantics(
            label: 'Barra de viagem no tempo, turno $currentTurn de $maxIndex',
            slider: true,
            child: Slider(
              value: currentIndex.toDouble(),
              min: 0,
              max: maxIndex.toDouble(),
              divisions: sliderActive ? maxIndex : null,
              onChanged: sliderActive
                  ? (double v) =>
                        ref.read(timeMachineProvider.notifier).jumpTo(v.round())
                  : null,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _HudButton(
                label: '⏪  Undo',
                enabled: canUndo,
                onPressed: () => ref.read(timeMachineProvider.notifier).undo(),
              ),
              _HudButton(
                label: '⏩  Redo',
                enabled: canRedo,
                onPressed: () => ref.read(timeMachineProvider.notifier).redo(),
              ),
            ],
          ),
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
