import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/models/transaction_type.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final _monthlyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final expenseTotal = state.transactions.where((e) => e.type == TransactionType.expense).fold<double>(0, (s, e) => s + e.amount);
    _monthlyController.text = state.budget.monthlyBudget.toStringAsFixed(0);
    final ratio = state.budget.monthlyBudget <= 0 ? 0 : (expenseTotal / state.budget.monthlyBudget).clamp(0.0, 1.0);
    final color = ratio < 0.6 ? Colors.green : ratio < 0.9 ? Colors.orange : Colors.red;

    return Scaffold(
      appBar: AppBar(title: const Text('Budget Planning')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _monthlyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monthly Budget')),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              final monthly = double.tryParse(_monthlyController.text) ?? 0;
              await ref.read(appStateProvider.notifier).setBudget(monthly, state.budget.categoryBudgets);
            },
            child: const Text('Save Budget'),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: ratio, color: color, minHeight: 14, borderRadius: BorderRadius.circular(16)),
          const SizedBox(height: 8),
          Text('Spent ${state.settings.currency} ${expenseTotal.toStringAsFixed(2)} / ${state.budget.monthlyBudget.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}
