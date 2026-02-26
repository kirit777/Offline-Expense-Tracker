import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/hive_service.dart';
import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../models/payment_method.dart';
import '../models/recurrence_frequency.dart';
import '../models/settings_model.dart';
import '../models/transaction_model.dart';
import '../models/transaction_type.dart';

class ExpenseRepository {
  ExpenseRepository() : _uuid = const Uuid();

  final Uuid _uuid;

  Box<TransactionModel> get _transactionBox => Hive.box<TransactionModel>(HiveService.transactionBox);
  Box<CategoryModel> get _categoryBox => Hive.box<CategoryModel>(HiveService.categoryBox);
  Box<SettingsModel> get _settingsBox => Hive.box<SettingsModel>(HiveService.settingsBox);
  Box<BudgetModel> get _budgetBox => Hive.box<BudgetModel>(HiveService.budgetBox);

  Future<void> seedDefaults() async {
    if (_categoryBox.isEmpty) {
      final defaults = [
        CategoryModel(id: _uuid.v4(), name: 'Food', iconCodePoint: 0xe56c, colorValue: 0xffef5350, isDefault: true),
        CategoryModel(id: _uuid.v4(), name: 'Transport', iconCodePoint: 0xe531, colorValue: 0xff42a5f5, isDefault: true),
        CategoryModel(id: _uuid.v4(), name: 'Rent', iconCodePoint: 0xe88a, colorValue: 0xffab47bc, isDefault: true),
        CategoryModel(id: _uuid.v4(), name: 'Salary', iconCodePoint: 0xe227, colorValue: 0xff66bb6a, isDefault: true),
        CategoryModel(id: _uuid.v4(), name: 'Bills', iconCodePoint: 0xe0b7, colorValue: 0xffffa726, isDefault: true),
        CategoryModel(id: _uuid.v4(), name: 'Shopping', iconCodePoint: 0xe59c, colorValue: 0xff7e57c2, isDefault: true),
        CategoryModel(id: _uuid.v4(), name: 'Health', iconCodePoint: 0xe3af, colorValue: 0xff26a69a, isDefault: true),
        CategoryModel(id: _uuid.v4(), name: 'Education', iconCodePoint: 0xe80c, colorValue: 0xff5c6bc0, isDefault: true),
        CategoryModel(id: _uuid.v4(), name: 'Entertainment', iconCodePoint: 0xe40f, colorValue: 0xffec407a, isDefault: true),
      ];
      for (final category in defaults) {
        await _categoryBox.put(category.id, category);
      }
    }

    if (_settingsBox.isEmpty) {
      await _settingsBox.put('app', SettingsModel(currency: 'USD', themeMode: 0, isBiometricEnabled: false, isPinEnabled: false, onboardingCompleted: false));
    }

    if (_budgetBox.isEmpty) {
      await _budgetBox.put('budget', BudgetModel(monthlyBudget: 0, categoryBudgets: {}));
    }
  }

  List<TransactionModel> transactions() => _transactionBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  List<CategoryModel> categories() => _categoryBox.values.toList()..sort((a, b) => a.name.compareTo(b.name));

  SettingsModel settings() => _settingsBox.get('app')!;
  BudgetModel budget() => _budgetBox.get('budget')!;

  Future<void> saveTransaction(TransactionModel transaction) async => _transactionBox.put(transaction.id, transaction);
  Future<void> deleteTransaction(String id) async => _transactionBox.delete(id);

  String nextId() => _uuid.v4();

  Future<void> saveCategory(CategoryModel category) async => _categoryBox.put(category.id, category);

  Future<void> deleteCategory(String id) async {
    final linked = _transactionBox.values.where((tx) => tx.categoryId == id);
    if (linked.isNotEmpty) {
      throw StateError('Cannot delete category with transactions.');
    }
    await _categoryBox.delete(id);
  }

  Future<void> saveSettings(SettingsModel settings) async => _settingsBox.put('app', settings);
  Future<void> saveBudget(BudgetModel budget) async => _budgetBox.put('budget', budget);

  Future<void> clearAll() async {
    await Future.wait([
      _transactionBox.clear(),
      _categoryBox.clear(),
      _budgetBox.clear(),
    ]);
    await seedDefaults();
  }

  Future<List<int>> buildPdfReport({required DateTimeRange range, required String currency}) async {
    final reportTx = transactions().where((tx) => !tx.date.isBefore(range.start) && !tx.date.isAfter(range.end)).toList();
    final income = reportTx.where((e) => e.type == TransactionType.income).fold<double>(0, (sum, e) => sum + e.amount);
    final expense = reportTx.where((e) => e.type == TransactionType.expense).fold<double>(0, (sum, e) => sum + e.amount);
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text('Offline Expense Tracker', style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Range: ${DateFormat.yMMMd().format(range.start)} - ${DateFormat.yMMMd().format(range.end)}'),
          pw.SizedBox(height: 12),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text('Income: $currency ${income.toStringAsFixed(2)}'),
            pw.Text('Expense: $currency ${expense.toStringAsFixed(2)}'),
            pw.Text('Balance: $currency ${(income - expense).toStringAsFixed(2)}'),
          ]),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: const ['Date', 'Title', 'Category', 'Type', 'Amount'],
            data: reportTx
                .map((tx) => [
                      DateFormat.yMd().add_jm().format(tx.date),
                      tx.title,
                      categories().firstWhere((c) => c.id == tx.categoryId).name,
                      tx.type.name,
                      '$currency ${tx.amount.toStringAsFixed(2)}',
                    ])
                .toList(),
          ),
        ],
      ),
    );
    return doc.save();
  }

  Future<void> printPdf(List<int> pdfBytes) => Printing.layoutPdf(onLayout: (_) async => pdfBytes);

  String exportCsv({required DateTimeRange range, required String currency}) {
    final rows = <List<dynamic>>[
      ['Date', 'Title', 'Category', 'Type', 'Payment Method', 'Amount', 'Currency', 'Notes'],
    ];
    for (final tx in transactions().where((tx) => !tx.date.isBefore(range.start) && !tx.date.isAfter(range.end))) {
      final categoryName = categories().firstWhere((c) => c.id == tx.categoryId).name;
      rows.add([
        tx.date.toIso8601String(),
        tx.title,
        categoryName,
        tx.type.name,
        tx.paymentMethod.name,
        tx.amount.toStringAsFixed(2),
        currency,
        tx.notes,
      ]);
    }
    return const ListToCsvConverter().convert(rows);
  }

  Future<void> runRecurringTrigger(DateTime now) async {
    final all = transactions().where((tx) => tx.isRecurringEnabled && tx.recurrence != RecurrenceFrequency.none).toList();
    for (final tx in all) {
      final lastRun = tx.lastRecurringRun ?? tx.date;
      final shouldRun = switch (tx.recurrence) {
        RecurrenceFrequency.daily => now.difference(lastRun).inDays >= 1,
        RecurrenceFrequency.weekly => now.difference(lastRun).inDays >= 7,
        RecurrenceFrequency.monthly => now.month != lastRun.month || now.year != lastRun.year,
        RecurrenceFrequency.custom => now.difference(lastRun).inDays >= (tx.customRecurrenceDays ?? 30),
        RecurrenceFrequency.none => false,
      };
      if (shouldRun) {
        await saveTransaction(tx.copyWith(
          id: nextId(),
          date: now,
          lastRecurringRun: now,
          isRecurringEnabled: false,
          recurrence: RecurrenceFrequency.none,
          customRecurrenceDays: null,
        ));
        await saveTransaction(tx.copyWith(lastRecurringRun: now));
      }
    }
  }

  String toBackupJson() {
    final payload = {
      'transactions': transactions()
          .map((tx) => {
                'id': tx.id,
                'title': tx.title,
                'amount': tx.amount,
                'type': tx.type.index,
                'categoryId': tx.categoryId,
                'date': tx.date.toIso8601String(),
                'notes': tx.notes,
                'paymentMethod': tx.paymentMethod.index,
                'recurrence': tx.recurrence.index,
                'customRecurrenceDays': tx.customRecurrenceDays,
                'isRecurringEnabled': tx.isRecurringEnabled,
                'lastRecurringRun': tx.lastRecurringRun?.toIso8601String(),
              })
          .toList(),
      'categories': categories()
          .map((c) => {
                'id': c.id,
                'name': c.name,
                'icon': c.iconCodePoint,
                'color': c.colorValue,
                'isDefault': c.isDefault,
              })
          .toList(),
      'budget': {
        'monthlyBudget': budget().monthlyBudget,
        'categoryBudgets': budget().categoryBudgets,
      },
    };
    return jsonEncode(payload);
  }

  Future<void> restoreFromJson(String jsonData) async {
    final map = jsonDecode(jsonData) as Map<String, dynamic>;
    await clearAll();
    for (final cat in map['categories'] as List<dynamic>) {
      final c = cat as Map<String, dynamic>;
      await saveCategory(CategoryModel(
        id: c['id'] as String,
        name: c['name'] as String,
        iconCodePoint: c['icon'] as int,
        colorValue: c['color'] as int,
        isDefault: c['isDefault'] as bool,
      ));
    }
    for (final item in map['transactions'] as List<dynamic>) {
      final tx = item as Map<String, dynamic>;
      await saveTransaction(TransactionModel(
        id: tx['id'] as String,
        title: tx['title'] as String,
        amount: (tx['amount'] as num).toDouble(),
        type: TransactionType.values[tx['type'] as int],
        categoryId: tx['categoryId'] as String,
        date: DateTime.parse(tx['date'] as String),
        notes: tx['notes'] as String,
        paymentMethod: PaymentMethod.values[tx['paymentMethod'] as int],
        recurrence: RecurrenceFrequency.values[tx['recurrence'] as int],
        customRecurrenceDays: tx['customRecurrenceDays'] as int?,
        isRecurringEnabled: tx['isRecurringEnabled'] as bool,
        lastRecurringRun: tx['lastRecurringRun'] == null ? null : DateTime.parse(tx['lastRecurringRun'] as String),
      ));
    }
    final budgetData = map['budget'] as Map<String, dynamic>;
    await saveBudget(BudgetModel(
      monthlyBudget: (budgetData['monthlyBudget'] as num).toDouble(),
      categoryBudgets: Map<String, double>.from((budgetData['categoryBudgets'] as Map).map((key, value) => MapEntry(key as String, (value as num).toDouble()))),
    ));
  }
}
