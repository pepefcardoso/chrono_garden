import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:chrono_garden/features/game/views/game_screen.dart';
import 'package:chrono_garden/features/menu/views/menu_screen.dart';
import 'package:chrono_garden/features/menu/views/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: <RouteBase>[
    GoRoute(
      path: '/splash',
      builder: (BuildContext context, GoRouterState state) =>
          const SplashScreen(),
    ),
    GoRoute(
      path: '/menu',
      builder: (BuildContext context, GoRouterState state) =>
          const MenuScreen(),
    ),
    GoRoute(
      path: '/game',
      builder: (BuildContext context, GoRouterState state) =>
          const GameScreen(),
    ),
  ],
);