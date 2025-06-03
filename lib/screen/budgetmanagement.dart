import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ExpenseApp extends StatefulWidget {
  const ExpenseApp({super.key});

  @override
  _ExpenseHomePageState createState() => _ExpenseHomePageState();
}

class Expense {
  String title;
  double amount;

  Expense({required this.title, required this.amount});

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      title: json['title'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
    };
  }
}

class ExpenseHomePage extends StatefulWidget {
  @override
  _ExpenseHomePageState createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    loadExpenseList();
  }

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  Future<void> saveExpenseList(List<Expense> expenses) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonStringList = expenses.map((expense) => jsonEncode(expense.toJson())).toList();
    await prefs.setStringList('expense_list', jsonStringList);
  }

  Future<void> loadExpenseList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonStringList = prefs.getStringList('expense_list');

    if (jsonStringList != null) {
      setState(() {
        _expenses = jsonStringList.map((jsonString) => Expense.fromJson(jsonDecode(jsonString))).toList();
      });
    }
  }

  void _addExpense() async {
    String title = _titleController.text;
    double? amount = double.tryParse(_amountController.text);

    if (title.isEmpty || amount == null || amount <= 0) return;

    _expenses.add(Expense(title: title, amount: amount));
    await saveExpenseList(_expenses);

    setState(() {});

    _titleController.clear();
    _amountController.clear();

    Navigator.of(context).pop();
  }

  void _deleteExpense(int index) async {
    _expenses.removeAt(index);
    await saveExpenseList(_expenses);

    setState(() {});
  }

  void _editExpense(int index) async {
    final expense = _expenses[index];
    _titleController.text = expense.title;
    _amountController.text = expense.amount.toString();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Edit Expense', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(12),
                  backgroundColor: Colors.teal,
                ),
                child: Text('Save Changes'),
                onPressed: () async {
                  String updatedTitle = _titleController.text;
                  double? updatedAmount = double.tryParse(_amountController.text);

                  if (updatedTitle.isEmpty || updatedAmount == null || updatedAmount <= 0) return;

                  _expenses[index] = Expense(title: updatedTitle, amount: updatedAmount);
                  await saveExpenseList(_expenses);

                  setState(() {});

                  _titleController.clear();
                  _amountController.clear();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddExpenseModal() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add New Expense', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(12),
                  backgroundColor: Colors.teal,
                ),
                child: Text('Add Expense'),
                onPressed: _addExpense,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NaKSimPan - Expenses'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddExpenseModal,
          ),
        ],
      ),
      body: _expenses.isEmpty
          ? Center(child: Text('No expenses added yet!', style: TextStyle(fontSize: 18)))
          : ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (ctx, index) {
                final exp = _expenses[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(exp.title, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('RM${exp.amount.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.edit, color: Colors.orange), onPressed: () => _editExpense(index)),
                        IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteExpense(index)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
