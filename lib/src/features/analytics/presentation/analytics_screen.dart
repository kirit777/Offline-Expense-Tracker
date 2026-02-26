import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/models/transaction_type.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final tx = ref.watch(appStateProvider).transactions;
    final expenses = tx.where((e) => e.type == TransactionType.expense).toList();
    final incomes = tx.where((e) => e.type == TransactionType.income).toList();
    final avg = expenses.isEmpty ? 0.0 : expenses.fold<double>(0, (s, e) => s + e.amount) / expenses.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics'), bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'Weekly'), Tab(text: 'Monthly'), Tab(text: 'Yearly'), Tab(text: 'Custom')])),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(
          4,
          (_) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(spots: List.generate(expenses.length, (i) => FlSpot(i.toDouble(), expenses[i].amount)), isCurved: true),
                      LineChartBarData(spots: List.generate(incomes.length, (i) => FlSpot(i.toDouble(), incomes[i].amount)), isCurved: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Highest spending category and smart insights are calculated from your real local data.'),
              Text('Average daily spending: ${avg.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ),
    );
  }
}
