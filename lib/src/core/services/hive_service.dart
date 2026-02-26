import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/budget_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/settings_model.dart';
import '../../data/models/transaction_model.dart';

class HiveService {
  static const transactionBox = 'transactions_box';
  static const categoryBox = 'categories_box';
  static const settingsBox = 'settings_box';
  static const budgetBox = 'budget_box';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive
      ..registerAdapter(CategoryModelAdapter())
      ..registerAdapter(TransactionModelAdapter())
      ..registerAdapter(BudgetModelAdapter())
      ..registerAdapter(SettingsModelAdapter());

    await Future.wait([
      Hive.openBox<TransactionModel>(transactionBox),
      Hive.openBox<CategoryModel>(categoryBox),
      Hive.openBox<SettingsModel>(settingsBox),
      Hive.openBox<BudgetModel>(budgetBox),
    ]);
  }
}
