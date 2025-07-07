import 'package:flutter/material.dart';

import '../model/expense.dart';

class ExpenseListView extends StatelessWidget {
  final List<Expense> expenses;
  final void Function(int index) onEdit;
  final void Function(List<Expense> expenses, int index) onDelete;
  final void Function(Expense expense) onRepeat;

  const ExpenseListView({
    required this.expenses,
    required this.onEdit,
    required this.onDelete,
    required this.onRepeat,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Center(child: Text('No expenses added yet!'));
    }

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (ctx, index) {
        final exp = expenses[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Repeat Expense'),
                content: Text('Repeat "${exp.title}" for RM${exp.amount.toStringAsFixed(2)}?'),
                actions: [
                  TextButton(child: Text('Cancel'), onPressed: () => Navigator.pop(context)),
                  ElevatedButton(
                    child: Text('Confirm'),
                    onPressed: () {
                      Navigator.pop(context);
                      onRepeat(exp);
                    },
                  ),
                ],
              ),
            ),
            title: Text(exp.title, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('RM${exp.amount.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.edit, color: Colors.orange), onPressed: () => onEdit(index)),
                IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => onDelete(expenses, index)),
              ],
            ),
          ),
        );
      },
    );
  }
}
