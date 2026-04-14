import 'package:flutter/material.dart';

import 'package:chrono_garden/core/theme/app_theme.dart';
import 'package:chrono_garden/features/game/models/cell_data.dart';
import 'package:chrono_garden/features/game/models/plant_type.dart';

abstract final class CellPainter {
  static const Map<PlantType, Color> _fillMap = <PlantType, Color>{
    PlantType.empty: AppColors.secondary,
    PlantType.obstacle: Color(0xFF4E342E),
    PlantType.seed: Color(0xFFA5D6A7),
    PlantType.sprout: Color(0xFF66BB6A),
    PlantType.youngPlant: AppColors.primary,
    PlantType.maturePlant: Color(0xFF2E7D32),
  };

  static const Map<PlantType, String> iconMap = <PlantType, String>{
    PlantType.empty: '',
    PlantType.obstacle: '🪨',
    PlantType.seed: '🌱',
    PlantType.sprout: '🌿',
    PlantType.youngPlant: '🪴',
    PlantType.maturePlant: '🌳',
  };

  static Color colorFor(PlantType type) =>
      _fillMap[type] ?? AppColors.secondary;

  static String iconFor(PlantType type) => iconMap[type] ?? '';

  static BoxDecoration decorationFor(CellData cell) {
    final BoxDecoration base = BoxDecoration(
      color: colorFor(cell.type),
      borderRadius: BorderRadius.circular(4),
    );

    if (cell.isGoalCell) {
      return base.copyWith(
        border: Border.all(color: AppColors.tertiary, width: 2.5),
        borderRadius: BorderRadius.circular(6),
      );
    }

    return base;
  }

  static bool isTappable(CellData cell) => cell.type == PlantType.empty;
}
