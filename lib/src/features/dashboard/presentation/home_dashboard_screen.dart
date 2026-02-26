import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/transaction_type.dart';
import '../../shared/widgets/amount_text.dart';
import '../../shared/widgets/premium_card.dart';
import '../../transactions/presentation/add_edit_transaction_screen.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final monthTx = state.transactions.where((tx) => tx.date.month == DateTime.now().month && tx.date.year == DateTime.now().year).toList();
    final income = monthTx.where((e) => e.type == TransactionType.income).fold<double>(0, (s, e) => s + e.amount);
    final expense = monthTx.where((e) => e.type == TransactionType.expense).fold<double>(0, (s, e) => s + e.amount);
    final savings = income - expense;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text(DateFormat.yMMMM().format(DateTime.now())),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Balance', style: Theme.of(context).textTheme.labelLarge),
                    Text('${state.settings.currency} ${savings.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AmountText(amount: income, type: TransactionType.income, currency: state.settings.currency),
                        AmountText(amount: expense, type: TransactionType.expense, currency: state.settings.currency),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PremiumCard(
                child: SizedBox(
                  height: 190,
                  child: BarChart(
                    BarChartData(
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: income, color: AppTheme.income)]),
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: expense, color: AppTheme.expense)]),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 44)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(value == 0 ? 'Income' : 'Expense'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PremiumCard(
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: state.categories
                          .map(
                            (c) => PieChartSectionData(
                              color: Color(c.colorValue),
                              value: monthTx.where((tx) => tx.categoryId == c.id).fold<double>(0, (s, e) => s + e.amount),
                              title: c.name,
                              radius: 58,
                            ),
                          )
                          .where((e) => e.value > 0)
                          .toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Recent Transactions', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...state.transactions.take(8).map(
                    (tx) => Dismissible(
                      key: ValueKey(tx.id),
                      background: Container(color: Colors.redAccent),
                      secondaryBackground: Container(color: Colors.blueAccent),
                      confirmDismiss: (dir) async {
                        if (dir == DismissDirection.startToEnd) {
                          await ref.read(appStateProvider.notifier).deleteTransaction(tx.id);
                          return true;
                        }
                        await ref.read(appStateProvider.notifier).duplicateTransaction(tx);
                        return false;
                      },
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        tileColor: Theme.of(context).colorScheme.surface,
                        leading: CircleAvatar(
                          backgroundColor: Color(state.categories.firstWhere((c) => c.id == tx.categoryId).colorValue).withValues(alpha: 0.2),
                          child: Icon(IconData(state.categories.firstWhere((c) => c.id == tx.categoryId).iconCodePoint, fontFamily: 'MaterialIcons')),
                        ),
                        title: Text(tx.title),
                        subtitle: Text(DateFormat.yMd().add_jm().format(tx.date)),
                        trailing: AmountText(amount: tx.amount, type: tx.type, currency: state.settings.currency),
                        onLongPress: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddEditTransactionScreen(existing: tx))),
                      ),
                    ),
                  ),
            ]),
          ),
        ),
      ],
    );
  }
}
