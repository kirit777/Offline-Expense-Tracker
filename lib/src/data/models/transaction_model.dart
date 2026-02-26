import 'package:hive/hive.dart';

import 'payment_method.dart';
import 'recurrence_frequency.dart';
import 'transaction_type.dart';

class TransactionModel {
  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    required this.notes,
    required this.paymentMethod,
    required this.recurrence,
    this.customRecurrenceDays,
    this.isRecurringEnabled = false,
    this.lastRecurringRun,
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String notes;
  final PaymentMethod paymentMethod;
  final RecurrenceFrequency recurrence;
  final int? customRecurrenceDays;
  final bool isRecurringEnabled;
  final DateTime? lastRecurringRun;

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    DateTime? date,
    String? notes,
    PaymentMethod? paymentMethod,
    RecurrenceFrequency? recurrence,
    int? customRecurrenceDays,
    bool? isRecurringEnabled,
    DateTime? lastRecurringRun,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      recurrence: recurrence ?? this.recurrence,
      customRecurrenceDays: customRecurrenceDays ?? this.customRecurrenceDays,
      isRecurringEnabled: isRecurringEnabled ?? this.isRecurringEnabled,
      lastRecurringRun: lastRecurringRun ?? this.lastRecurringRun,
    );
  }
}

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 2;

  @override
  TransactionModel read(BinaryReader reader) {
    return TransactionModel(
      id: reader.readString(),
      title: reader.readString(),
      amount: reader.readDouble(),
      type: TransactionType.values[reader.readInt()],
      categoryId: reader.readString(),
      date: DateTime.parse(reader.readString()),
      notes: reader.readString(),
      paymentMethod: PaymentMethod.values[reader.readInt()],
      recurrence: RecurrenceFrequency.values[reader.readInt()],
      customRecurrenceDays: reader.read() as int?,
      isRecurringEnabled: reader.readBool(),
      lastRecurringRun: reader.read() as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.title)
      ..writeDouble(obj.amount)
      ..writeInt(obj.type.index)
      ..writeString(obj.categoryId)
      ..writeString(obj.date.toIso8601String())
      ..writeString(obj.notes)
      ..writeInt(obj.paymentMethod.index)
      ..writeInt(obj.recurrence.index)
      ..write(obj.customRecurrenceDays)
      ..writeBool(obj.isRecurringEnabled)
      ..write(obj.lastRecurringRun);
  }
}
