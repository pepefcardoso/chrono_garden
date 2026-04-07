import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: _ChronoGardenApp()));
}

class _ChronoGardenApp extends StatelessWidget {
  const _ChronoGardenApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Chrono Garden',
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: Text('Sprint 0 — Foundation OK'))),
    );
  }
}
