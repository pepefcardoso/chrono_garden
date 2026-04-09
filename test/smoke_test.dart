import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chrono_garden/core/router/app_router.dart';
import 'package:chrono_garden/core/theme/app_theme.dart';

void main() {
  testWidgets('App boots and renders splash route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: appRouter,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Splash'), findsOneWidget);
  });

  testWidgets('Theme scaffold background is #F1F8E9', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: Scaffold())),
    );

    final ThemeData theme = AppTheme.light;
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF1F8E9));
  });

  testWidgets('Theme primary color is Verde Natural #4CAF50', (
    WidgetTester tester,
  ) async {
    final ThemeData theme = AppTheme.light;
    expect(theme.colorScheme.primary, const Color(0xFF4CAF50));
  });

  testWidgets('Theme tertiary color is Cyan Digital #00E5FF', (
    WidgetTester tester,
  ) async {
    final ThemeData theme = AppTheme.light;
    expect(theme.colorScheme.tertiary, const Color(0xFF00E5FF));
  });

  testWidgets('ElevatedButton uses StadiumBorder (pill shape)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: ElevatedButton(onPressed: () {}, child: const Text('Plant')),
          ),
        ),
      ),
    );
    await tester.pump();

    final ThemeData theme = AppTheme.light;
    final OutlinedBorder? shape = theme.elevatedButtonTheme.style?.shape
        ?.resolve(<WidgetState>{});
    expect(shape, isA<StadiumBorder>());
  });
}
