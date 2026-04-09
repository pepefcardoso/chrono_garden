import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chrono_garden/core/router/app_router.dart';
import 'package:chrono_garden/core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: ChronoGardenApp()));
}

class ChronoGardenApp extends StatelessWidget {
  const ChronoGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Chrono Garden',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
