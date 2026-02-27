import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app/providers.dart';
import '../../../core/ads/ads_manager.dart';
import '../../../core/ads/banner_ad_widget.dart';
import '../../../data/models/transaction_type.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _isLoading = false);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdsManager.instance.showInterstitialAd();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const _DashboardSkeleton();

    final state = ref.watch(appStateProvider);
    final txs = state.transactions;
    final currency = NumberFormat.currency(symbol: '${state.settings.currency} ');

    final income = txs
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final expense = txs
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, item) => sum + item.amount);

    return RepaintBoundary(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _BalanceCard(balance: income - expense, income: income, expense: expense, formatter: currency),
          const SizedBox(height: 16),
          _InsightChart(income: income, expense: expense),
          const SizedBox(height: 16),
          const Align(alignment: Alignment.center, child: BannerAdWidget()),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance, required this.income, required this.expense, required this.formatter});

  final double balance;
  final double income;
  final double expense;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: balance),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, value, __) {
        return Card(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Balance', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary.withValues(alpha: 0.88))),
                const SizedBox(height: 8),
                Text(
                  formatter.format(value),
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.onPrimary),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _MetricPill(label: 'Income', value: formatter.format(income))),
                    const SizedBox(width: 8),
                    Expanded(child: _MetricPill(label: 'Expense', value: formatter.format(expense))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white.withValues(alpha: 0.16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightChart extends StatelessWidget {
  const _InsightChart({required this.income, required this.expense});

  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    final total = (income + expense).clamp(1, double.infinity);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending Insight', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 42,
                  sections: [
                    PieChartSectionData(value: income / total * 100, color: Theme.of(context).colorScheme.primary, title: 'Income'),
                    PieChartSectionData(value: expense / total * 100, color: Theme.of(context).colorScheme.tertiary, title: 'Expense'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SkelBox(height: 210),
          SizedBox(height: 16),
          _SkelBox(height: 230),
        ],
      ),
    );
  }
}

class _SkelBox extends StatelessWidget {
  const _SkelBox({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
