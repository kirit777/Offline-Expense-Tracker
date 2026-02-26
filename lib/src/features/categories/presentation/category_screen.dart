import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/models/category_model.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final c = state.categories[i];
          final total = state.transactions.where((tx) => tx.categoryId == c.id).fold<double>(0, (s, e) => s + e.amount);
          return ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            tileColor: Theme.of(context).colorScheme.surface,
            leading: CircleAvatar(backgroundColor: Color(c.colorValue), child: Icon(IconData(c.iconCodePoint, fontFamily: 'MaterialIcons'))),
            title: Text(c.name),
            subtitle: Text('Total: ${state.settings.currency} ${total.toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: c.isDefault
                  ? null
                  : () async {
                      try {
                        await ref.read(appStateProvider.notifier).deleteCategory(c.id);
                      } catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showCategoryDialog(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    int color = 0xff3949ab;
    int iconCode = Icons.category.codePoint;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            DropdownButtonFormField<int>(
              value: iconCode,
              items: [Icons.category, Icons.fastfood, Icons.directions_car, Icons.home, Icons.shopping_bag]
                  .map((icon) => DropdownMenuItem(value: icon.codePoint, child: Icon(icon)))
                  .toList(),
              onChanged: (v) => iconCode = v!,
            ),
            DropdownButtonFormField<int>(
              value: color,
              items: const [0xff3949ab, 0xff43a047, 0xffe53935, 0xff8e24aa, 0xffff8f00]
                  .map((value) => DropdownMenuItem(value: value, child: CircleAvatar(backgroundColor: Color(value))))
                  .toList(),
              onChanged: (v) => color = v!,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (name.text.trim().isEmpty) return;
              await ref.read(appStateProvider.notifier).saveCategory(CategoryModel(
                    id: ref.read(repositoryProvider).nextId(),
                    name: name.text.trim(),
                    iconCodePoint: iconCode,
                    colorValue: color,
                  ));
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
