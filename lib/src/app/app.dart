import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/theme.dart';
import 'providers.dart';
import 'router.dart';

class ExpenseTrackerApp extends ConsumerWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final modeIndex = appState.settings.themeMode;
    final themeMode =
        modeIndex >= 0 && modeIndex < ThemeMode.values.length ? ThemeMode.values[modeIndex] : ThemeMode.system;

    return MaterialApp.router(
      title: 'Offline Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
