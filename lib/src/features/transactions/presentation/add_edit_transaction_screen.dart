import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/models/payment_method.dart';
import '../../../data/models/recurrence_frequency.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  const AddEditTransactionScreen({super.key, this.existing});
  final TransactionModel? existing;

  @override
  ConsumerState<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends ConsumerState<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _title = TextEditingController();
  final _notes = TextEditingController();

  TransactionType _type = TransactionType.expense;
  PaymentMethod _method = PaymentMethod.cash;
  RecurrenceFrequency _recurrence = RecurrenceFrequency.none;
  int? _customDays;
  DateTime _dateTime = DateTime.now();
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    final tx = widget.existing;
    if (tx != null) {
      _amount.text = tx.amount.toString();
      _title.text = tx.title;
      _notes.text = tx.notes;
      _type = tx.type;
      _method = tx.paymentMethod;
      _recurrence = tx.recurrence;
      _customDays = tx.customRecurrenceDays;
      _dateTime = tx.date;
      _categoryId = tx.categoryId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(appStateProvider).categories;
    _categoryId ??= categories.isNotEmpty ? categories.first.id : null;
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Add Transaction' : 'Edit Transaction')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount'),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Amount required';
                final value = double.tryParse(v);
                if (value == null || value <= 0) return 'Enter valid amount';
                return null;
              },
            ),
            const SizedBox(height: 12),
            SegmentedButton<TransactionType>(
              selected: {_type},
              onSelectionChanged: (set) => setState(() => _type = set.first),
              segments: const [
                ButtonSegment(value: TransactionType.income, label: Text('Income')),
                ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _categoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date & Time'),
              subtitle: Text(_dateTime.toString()),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: _dateTime);
                if (date == null || !mounted) return;
                final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_dateTime));
                if (time == null) return;
                setState(() => _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute));
              },
            ),
            DropdownButtonFormField<PaymentMethod>(
              value: _method,
              decoration: const InputDecoration(labelText: 'Payment Method'),
              items: PaymentMethod.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name.toUpperCase()))).toList(),
              onChanged: (v) => setState(() => _method = v!),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              value: _recurrence != RecurrenceFrequency.none,
              title: const Text('Recurring transaction'),
              onChanged: (value) => setState(() => _recurrence = value ? RecurrenceFrequency.monthly : RecurrenceFrequency.none),
            ),
            if (_recurrence != RecurrenceFrequency.none) ...[
              DropdownButtonFormField<RecurrenceFrequency>(
                value: _recurrence,
                decoration: const InputDecoration(labelText: 'Frequency'),
                items: RecurrenceFrequency.values.where((e) => e != RecurrenceFrequency.none).map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                onChanged: (v) => setState(() => _recurrence = v!),
              ),
              if (_recurrence == RecurrenceFrequency.custom)
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Custom Days Interval'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _customDays = int.tryParse(v),
                ),
            ],
            const SizedBox(height: 12),
            TextFormField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes')),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final tx = TransactionModel(
                  id: widget.existing?.id ?? ref.read(repositoryProvider).nextId(),
                  title: _title.text.trim(),
                  amount: double.parse(_amount.text),
                  type: _type,
                  categoryId: _categoryId!,
                  date: _dateTime,
                  notes: _notes.text.trim(),
                  paymentMethod: _method,
                  recurrence: _recurrence,
                  customRecurrenceDays: _customDays,
                  isRecurringEnabled: _recurrence != RecurrenceFrequency.none,
                  lastRecurringRun: widget.existing?.lastRecurringRun,
                );
                await ref.read(appStateProvider.notifier).saveTransaction(tx);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
