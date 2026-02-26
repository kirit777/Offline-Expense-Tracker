import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/pin/presentation/pin_lock_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/dashboard/presentation/home_shell.dart';
import 'providers.dart';

class ExpenseTrackerApp extends ConsumerWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    return MaterialApp(
      title: 'Offline Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.values[appState.settings.themeMode],
      home: const SplashScreen(),
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/home': (_) => const HomeShell(),
        '/lock': (_) => const PinLockScreen(),
      },
    );
  }
}
