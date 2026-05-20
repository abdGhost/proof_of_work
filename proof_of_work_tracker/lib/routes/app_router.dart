import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/main_shell.dart';
import '../features/share/screens/share_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/shell',
      builder: (context, state) {
        final tab = state.extra as int? ?? 0;
        return MainShell(initialIndex: tab);
      },
    ),
    GoRoute(
      path: '/share',
      builder: (context, state) => const ShareScreen(),
      parentNavigatorKey: _rootNavigatorKey,
    ),
  ],
);
