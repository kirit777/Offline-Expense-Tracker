import 'package:hive/hive.dart';

class BudgetModel {
  BudgetModel({required this.monthlyBudget, required this.categoryBudgets});

  final double monthlyBudget;
  final Map<String, double> categoryBudgets;
}

class BudgetModelAdapter extends TypeAdapter<BudgetModel> {
  @override
  final int typeId = 3;

  @override
  BudgetModel read(BinaryReader reader) {
    return BudgetModel(
      monthlyBudget: reader.readDouble(),
      categoryBudgets: Map<String, double>.from(reader.readMap().map((key, value) => MapEntry(key as String, value as double))),
    );
  }

  @override
  void write(BinaryWriter writer, BudgetModel obj) {
    writer
      ..writeDouble(obj.monthlyBudget)
      ..writeMap(obj.categoryBudgets);
  }
}
