import 'package:flutter/material.dart';
import '../model/expense.dart';
import '../service/currency_input.dart';

class ExpenseFormBottomSheet extends StatelessWidget {
  final String title;
  final Expense? initialExpense;
  final void Function(String title, double amount) onSubmit;

  const ExpenseFormBottomSheet({
    required this.title,
    required this.onSubmit,
    this.initialExpense,
  });

  @override
  Widget build(BuildContext context) {
    final _titleController = TextEditingController(text: initialExpense?.title ?? '');
    final _amountController = TextEditingController(
      text: initialExpense != null ? initialExpense?.amount.toStringAsFixed(2) : '',
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: EdgeInsets.all(12), backgroundColor: Colors.teal),
              onPressed: () {
                final title = _titleController.text;
                final raw = _amountController.text.replaceAll(',', '');
                final amount = double.tryParse(raw);

                if (title.isNotEmpty && amount != null && amount > 0) {
                  onSubmit(title, amount);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
