import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../data/models/budget_model.dart';
import '../data/models/category_model.dart';
import '../data/models/settings_model.dart';
import '../data/models/transaction_model.dart';
import '../data/models/transaction_type.dart';
import '../data/repositories/expense_repository.dart';

final repositoryProvider = Provider<ExpenseRepository>((ref) => ExpenseRepository());

final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(AppStateNotifier.new);

class AppState {
  const AppState({
    required this.transactions,
    required this.categories,
    required this.settings,
    required this.budget,
    required this.locked,
  });

  final List<TransactionModel> transactions;
  final List<CategoryModel> categories;
  final SettingsModel settings;
  final BudgetModel budget;
  final bool locked;

  AppState copyWith({
    List<TransactionModel>? transactions,
    List<CategoryModel>? categories,
    SettingsModel? settings,
    BudgetModel? budget,
    bool? locked,
  }) {
    return AppState(
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      settings: settings ?? this.settings,
      budget: budget ?? this.budget,
      locked: locked ?? this.locked,
    );
  }
}

class AppStateNotifier extends Notifier<AppState> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  @override
  AppState build() {
    _boot();
    return AppState(
      transactions: const [],
      categories: const [],
      settings: SettingsModel(currency: 'USD', themeMode: 0, isBiometricEnabled: false, isPinEnabled: false, onboardingCompleted: false),
      budget: BudgetModel(monthlyBudget: 0, categoryBudgets: {}),
      locked: false,
    );
  }

  Future<void> _boot() async {
    await ref.read(repositoryProvider).seedDefaults();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _notifications.initialize(initSettings);
    await ref.read(repositoryProvider).runRecurringTrigger(DateTime.now());
    _refresh();
  }

  void _refresh() {
    final repo = ref.read(repositoryProvider);
    state = state.copyWith(
      transactions: repo.transactions(),
      categories: repo.categories(),
      settings: repo.settings(),
      budget: repo.budget(),
    );
  }

  Future<void> saveTransaction(TransactionModel tx) async {
    await ref.read(repositoryProvider).saveTransaction(tx);
    HapticFeedback.lightImpact();
    _refresh();
  }

  Future<void> deleteTransaction(String id) async {
    await ref.read(repositoryProvider).deleteTransaction(id);
    HapticFeedback.mediumImpact();
    _refresh();
  }

  Future<void> duplicateTransaction(TransactionModel tx) async {
    await saveTransaction(tx.copyWith(id: ref.read(repositoryProvider).nextId(), date: DateTime.now()));
  }

  Future<void> saveCategory(CategoryModel category) async {
    await ref.read(repositoryProvider).saveCategory(category);
    _refresh();
  }

  Future<void> deleteCategory(String id) async {
    await ref.read(repositoryProvider).deleteCategory(id);
    _refresh();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final updated = state.settings.copyWith(themeMode: mode.index);
    await ref.read(repositoryProvider).saveSettings(updated);
    _refresh();
  }

  Future<void> setCurrency(String currency) async {
    final updated = state.settings.copyWith(currency: currency);
    await ref.read(repositoryProvider).saveSettings(updated);
    _refresh();
  }

  Future<void> setOnboardingCompleted() async {
    final updated = state.settings.copyWith(onboardingCompleted: true);
    await ref.read(repositoryProvider).saveSettings(updated);
    _refresh();
  }

  Future<void> setBudget(double monthlyBudget, Map<String, double> categoryBudgets) async {
    await ref.read(repositoryProvider).saveBudget(BudgetModel(monthlyBudget: monthlyBudget, categoryBudgets: categoryBudgets));
    _refresh();
  }

  Future<bool> unlockWithBiometricOrPin() async {
    if (!state.settings.isBiometricEnabled && !state.settings.isPinEnabled) {
      return true;
    }

    bool ok = false;
    if (state.settings.isBiometricEnabled) {
      ok = await _localAuth.authenticate(localizedReason: 'Unlock Expense Tracker', options: const AuthenticationOptions(biometricOnly: true));
    }

    if (!ok && state.settings.isPinEnabled) {
      final pin = await _secureStorage.read(key: 'app_pin');
      if (pin != null) {
        // Keeping a simple local pin flow; UI requests pin and validates in isPinValid.
      }
    }

    state = state.copyWith(locked: !ok);
    return ok;
  }

  Future<void> setPin(String pin) async {
    await _secureStorage.write(key: 'app_pin', value: pin);
    final updated = state.settings.copyWith(isPinEnabled: true);
    await ref.read(repositoryProvider).saveSettings(updated);
    _refresh();
  }

  Future<bool> isPinValid(String pin) async {
    final saved = await _secureStorage.read(key: 'app_pin');
    return saved == pin;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final updated = state.settings.copyWith(isBiometricEnabled: enabled);
    await ref.read(repositoryProvider).saveSettings(updated);
    _refresh();
  }

  Future<void> setPinEnabled(bool enabled) async {
    final updated = state.settings.copyWith(isPinEnabled: enabled);
    await ref.read(repositoryProvider).saveSettings(updated);
    _refresh();
  }

  Future<void> scheduleReminder(TimeOfDay time) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'expense_reminders',
        'Expense reminders',
        channelDescription: 'Daily reminder to record expenses',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _notifications.showDailyAtTime(
      101,
      'Track your spending',
      'Don\'t forget to log today\'s expenses.',
      Time(time.hour, time.minute, 0),
      details,
    );
  }

  Future<void> exportPdf(DateTimeRange range) async {
    final bytes = await ref.read(repositoryProvider).buildPdfReport(range: range, currency: state.settings.currency);
    await ref.read(repositoryProvider).printPdf(bytes);
  }

  Future<void> exportCsv(DateTimeRange range) async {
    final csv = ref.read(repositoryProvider).exportCsv(range: range, currency: state.settings.currency);
    final path = await FilePicker.platform.saveFile(dialogTitle: 'Save CSV', fileName: 'expense_report.csv');
    if (path != null) {
      await File(path).writeAsString(csv);
    }
  }

  Future<void> backupData() async {
    final json = ref.read(repositoryProvider).toBackupJson();
    final path = await FilePicker.platform.saveFile(dialogTitle: 'Save Backup', fileName: 'expense_backup.json');
    if (path != null) {
      await File(path).writeAsString(json);
    }
  }

  Future<void> restoreData() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (result?.files.single.path != null) {
      final file = File(result!.files.single.path!);
      await ref.read(repositoryProvider).restoreFromJson(await file.readAsString());
      _refresh();
    }
  }

  Future<void> deleteAll() async {
    await ref.read(repositoryProvider).clearAll();
    _refresh();
  }
}
