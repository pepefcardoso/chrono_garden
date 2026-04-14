import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chrono_garden/core/theme/app_theme.dart';
import 'package:chrono_garden/features/game/models/cell_data.dart';
import 'package:chrono_garden/features/game/models/grid_data.dart';
import 'package:chrono_garden/features/game/models/plant_type.dart';
import 'package:chrono_garden/features/game/notifiers/time_machine_notifier.dart';
import 'package:chrono_garden/features/game/views/widgets/cell_painter.dart';

class GameBoard extends HookConsumerWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GridData grid = ref.watch(
      timeMachineProvider.select((TimeMachineState s) => s.current.grid),
    );

    return AspectRatio(
      aspectRatio: grid.cols / grid.rows,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.neutral,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: AppColors.shadowBrown,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: grid.cols,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: grid.cells.length,
          itemBuilder: (BuildContext context, int index) {
            final int row = index ~/ grid.cols;
            final int col = index % grid.cols;
            final CellData cell = grid.cells[index];

            return _CellTile(
              key: ValueKey<int>(index),
              cell: cell,
              row: row,
              col: col,
            );
          },
        ),
      ),
    );
  }
}

class _CellTile extends ConsumerWidget {
  const _CellTile({
    required this.cell,
    required this.row,
    required this.col,
    super.key,
  });

  final CellData cell;
  final int row;
  final int col;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool tappable = CellPainter.isTappable(cell);

    return GestureDetector(
      onTap: tappable
          ? () => ref
                .read(timeMachineProvider.notifier)
                .plantSeed(row: row, col: col)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: CellPainter.decorationFor(cell),
        child: _CellIcon(type: cell.type, isGoalCell: cell.isGoalCell),
      ),
    );
  }
}

class _CellIcon extends StatelessWidget {
  const _CellIcon({required this.type, required this.isGoalCell});

  final PlantType type;
  final bool isGoalCell;

  @override
  Widget build(BuildContext context) {
    final String icon = CellPainter.iconFor(type);
    if (icon.isEmpty) {
      if (isGoalCell) {
        return Center(
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.tertiary,
              shape: BoxShape.circle,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          icon,
          style: const TextStyle(fontSize: 20),
          textScaler: TextScaler.noScaling,
        ),
      ),
    );
  }
}
