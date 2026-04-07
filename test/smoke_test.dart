import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('ProviderScope mounts without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Text('OK'),
          ),
        ),
      ),
    );

    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('App title resolves correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          title: 'Chrono Garden',
          home: Scaffold(
            body: Center(child: Text('Sprint 0 — Foundation OK')),
          ),
        ),
      ),
    );

    expect(find.text('Sprint 0 — Foundation OK'), findsOneWidget);
  });
}