import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = const [
      ('Offline Privacy', 'Your financial data stays on-device with no cloud requirement.', Icons.lock_outline),
      ('Smart Analytics', 'Actionable charts and trends for informed decisions.', Icons.bar_chart_rounded),
      ('Budget Planning', 'Set spending limits and track progress in real-time.', Icons.savings_outlined),
      ('Export Ready', 'Generate professional PDF and CSV reports anytime.', Icons.picture_as_pdf_outlined),
    ];
    final controller = PageController();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: pages.length,
                itemBuilder: (_, i) {
                  final item = pages[i];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.$3, size: 86),
                      const SizedBox(height: 20),
                      Text(item.$1, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Text(item.$2, textAlign: TextAlign.center),
                    ],
                  );
                },
              ),
            ),
            FilledButton(
              onPressed: () async {
                await ref.read(appStateProvider.notifier).setOnboardingCompleted();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
