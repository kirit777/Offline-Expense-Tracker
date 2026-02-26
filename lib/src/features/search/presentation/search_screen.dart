import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _query = '';
  RangeValues _range = const RangeValues(0, 10000);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final filtered = state.transactions.where((tx) {
      final category = state.categories.firstWhere((c) => c.id == tx.categoryId).name.toLowerCase();
      return tx.title.toLowerCase().contains(_query.toLowerCase()) &&
          category.contains(_query.toLowerCase()) &&
          tx.amount >= _range.start &&
          tx.amount <= _range.end;
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Search & Filters')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Title, category, payment method...'),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          RangeSlider(values: _range, min: 0, max: 10000, divisions: 100, labels: RangeLabels(_range.start.toStringAsFixed(0), _range.end.toStringAsFixed(0)), onChanged: (v) => setState(() => _range = v)),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(filtered[i].title),
                subtitle: Text(filtered[i].date.toString()),
                trailing: Text('${state.settings.currency} ${filtered[i].amount.toStringAsFixed(2)}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
