import 'package:flutter/material.dart';

import '../model/expense.dart';

class BudgetSummaryCard extends StatelessWidget {
  final double budget;
  final List<Expense> expenses;
  final double dailyBudget;
  final bool exceeded;
  final VoidCallback onEditBudget;
  final VoidCallback onSetGoal;

  const BudgetSummaryCard({
    required this.budget,
    required this.expenses,
    required this.dailyBudget,
    required this.exceeded,
    required this.onEditBudget,
    required this.onSetGoal,
  });

  @override
  Widget build(BuildContext context) {
    final spent = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final todaySpent = expenses
        .where((e) {
      final now = DateTime.now();
      return e.timestamp.year == now.year &&
          e.timestamp.month == now.month &&
          e.timestamp.day == now.day;
    })
        .fold(0.0, (sum, e) => sum + e.amount);

    return GestureDetector(
      onTap: onEditBudget,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Your Budget', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('RM${(budget - spent).toStringAsFixed(2)}', style: TextStyle(fontSize: 24, color: Colors.teal)),
                SizedBox(width: 6),
                Icon(Icons.edit, size: 20, color: Colors.teal),
              ],
            ),
            Text(
              'Daily Budget: RM${(dailyBudget - todaySpent).toStringAsFixed(2)}',
              style: TextStyle(fontSize: 14, color: exceeded ? Colors.red : Colors.grey[600]),
            ),
            Text('Total Budget: RM${budget.toStringAsFixed(2)}'),
            TextButton(onPressed: onSetGoal, child: Text('Set Savings Goal')),
          ],
        ),
      ),
    );
  }
}
