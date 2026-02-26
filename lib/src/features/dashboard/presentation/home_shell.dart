import 'package:flutter/material.dart';

import '../../analytics/presentation/analytics_screen.dart';
import '../../budgets/presentation/budget_screen.dart';
import '../../categories/presentation/category_screen.dart';
import '../../recurring/presentation/recurring_screen.dart';
import '../../search/presentation/search_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../transactions/presentation/add_edit_transaction_screen.dart';
import 'home_dashboard_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final screens = const [
    HomeDashboardScreen(),
    AnalyticsScreen(),
    BudgetScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddEditTransactionScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Manage')),
            ListTile(title: const Text('Categories'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryScreen()))),
            ListTile(title: const Text('Recurring'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecurringScreen()))),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.auto_graph_rounded), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Budget'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
