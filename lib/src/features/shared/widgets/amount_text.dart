import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/transaction_type.dart';

class AmountText extends StatelessWidget {
  const AmountText({super.key, required this.amount, required this.type, required this.currency});

  final double amount;
  final TransactionType type;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final color = type == TransactionType.income ? AppTheme.income : AppTheme.expense;
    return Text(
      '${type == TransactionType.income ? '+' : '-'}$currency ${amount.toStringAsFixed(2)}',
      style: TextStyle(color: color, fontWeight: FontWeight.w700),
    );
  }
}
