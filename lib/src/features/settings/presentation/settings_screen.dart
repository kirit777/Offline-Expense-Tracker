import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: state.settings.currency,
            decoration: const InputDecoration(labelText: 'Currency'),
            items: const ['USD', 'EUR', 'INR', 'GBP', 'JPY'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => ref.read(appStateProvider.notifier).setCurrency(v!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ThemeMode>(
            value: ThemeMode.values[state.settings.themeMode],
            decoration: const InputDecoration(labelText: 'Theme'),
            items: ThemeMode.values.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
            onChanged: (m) => ref.read(appStateProvider.notifier).setThemeMode(m!),
          ),
          SwitchListTile.adaptive(
            value: state.settings.isBiometricEnabled,
            onChanged: (v) => ref.read(appStateProvider.notifier).setBiometricEnabled(v),
            title: const Text('Enable Biometrics'),
          ),
          SwitchListTile.adaptive(
            value: state.settings.isPinEnabled,
            onChanged: (v) async {
              if (v) {
                await _setPin(context, ref);
              }
              await ref.read(appStateProvider.notifier).setPinEnabled(v);
            },
            title: const Text('Enable PIN lock'),
          ),
          FilledButton(
            onPressed: () => ref.read(appStateProvider.notifier).exportPdf(DateTimeRange(start: DateTime(DateTime.now().year, 1, 1), end: DateTime.now())),
            child: const Text('Export PDF'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => ref.read(appStateProvider.notifier).exportCsv(DateTimeRange(start: DateTime(DateTime.now().year, 1, 1), end: DateTime.now())),
            child: const Text('Export CSV'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () => ref.read(appStateProvider.notifier).backupData(), child: const Text('Local Backup')),
          OutlinedButton(onPressed: () => ref.read(appStateProvider.notifier).restoreData(), child: const Text('Restore Backup')),
          TextButton(
            onPressed: () async {
              final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Delete all data?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))])) ?? false;
              if (ok) {
                await ref.read(appStateProvider.notifier).deleteAll();
              }
            },
            child: const Text('Delete all data'),
          ),
          const ListTile(
            title: Text('About'),
            subtitle: Text('Offline Expense Tracker\nVersion 1.0.0\nPrivate, secure and fully offline.'),
          ),
        ],
      ),
    );
  }

  Future<void> _setPin(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set PIN'),
        content: TextField(controller: controller, keyboardType: TextInputType.number, obscureText: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (controller.text.length < 4) return;
              await ref.read(appStateProvider.notifier).setPin(controller.text);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save PIN'),
          ),
        ],
      ),
    );
  }
}
