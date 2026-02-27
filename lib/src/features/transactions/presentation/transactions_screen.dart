import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../data/models/transaction_type.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final txs = [...state.transactions]..sort((a, b) => b.date.compareTo(a.date));
    final currency = NumberFormat.currency(symbol: '${state.settings.currency} ');

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: txs.length,
        itemBuilder: (context, index) {
          final tx = txs[index];
          final isIncome = tx.type == TransactionType.income;
          final amountColor = isIncome ? Colors.green : Theme.of(context).colorScheme.error;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            margin: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: amountColor.withValues(alpha: 0.14),
                  child: Icon(isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: amountColor),
                ),
                title: Text(tx.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(DateFormat('dd MMM, yyyy • hh:mm a').format(tx.date)),
                trailing: Text(
                  '${isIncome ? '+' : '-'}${currency.format(tx.amount)}',
                  style: TextStyle(fontWeight: FontWeight.w700, color: amountColor),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
