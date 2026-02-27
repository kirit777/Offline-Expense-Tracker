import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/home_dashboard_screen.dart';
import '../features/dashboard/presentation/home_shell.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/transactions/presentation/transactions_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => HomeShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              pageBuilder: (context, state) => _buildFadeTransitionPage(const HomeDashboardScreen(), state),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/transactions',
              pageBuilder: (context, state) => _buildFadeTransitionPage(const TransactionsScreen(), state),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => _buildFadeTransitionPage(const SettingsScreen(), state),
            ),
          ],
        ),
      ],
    ),
  ],
);

CustomTransitionPage<void> _buildFadeTransitionPage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
  );
}
