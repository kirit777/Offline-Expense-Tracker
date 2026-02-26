import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/models/recurrence_frequency.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurring = ref.watch(appStateProvider).transactions.where((tx) => tx.recurrence != RecurrenceFrequency.none).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Transactions')),
      body: ListView.builder(
        itemCount: recurring.length,
        itemBuilder: (_, i) {
          final tx = recurring[i];
          return ListTile(
            title: Text(tx.title),
            subtitle: Text(tx.recurrence.name),
            trailing: IconButton(onPressed: () => ref.read(appStateProvider.notifier).deleteTransaction(tx.id), icon: const Icon(Icons.delete_outline)),
          );
        },
      ),
    );
  }
}
