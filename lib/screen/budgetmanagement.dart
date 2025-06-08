import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../model/expense.dart';
import '../service/budget_service.dart';
import 'loading_dialog.dart';
import 'login.dart';

class ExpenseHomePage extends StatefulWidget {
  @override
  _ExpenseHomePageState createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  late BudgetService _budgetService;
  List<Expense> _expenses = [];
  double _budget = 0.0;

  @override
  void initState() {
    super.initState();
    _budgetService = BudgetService(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(milliseconds: 500));
      await _loadExpenses();
      await _loadBudget();
      LoadingDialog.hide(context);
    });
  }

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  Future<void> _loadBudget() async {
    double loaded = await _budgetService.loadBudget();
    setState(() {
      _budget = loaded;
    });
  }

  Future<void> _loadExpenses() async {
    List<Expense> loaded = await _budgetService.loadExpenseList();
    setState(() {
      _expenses = loaded;
    });
  }

  void _addExpense() async {
    String title = _titleController.text;
    double? amount = double.tryParse(_amountController.text);
    String uuid = Uuid().v4();

    if (title.isEmpty || amount == null || amount <= 0) return;

    _expenses.clear();
    _expenses.add(Expense(title: title, amount: amount, uuid: uuid));
    await _budgetService.saveExpenseList(_expenses);

    setState(() {});

    _titleController.clear();
    _amountController.clear();

    Navigator.of(context).pop();
  }

  void _deleteExpense(List<Expense> expenses, int index) async {
    var uuid = expenses[index].uuid;

    if (FirebaseAuth.instance.currentUser != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('expenses').where('expense_list.uuid', isEqualTo: uuid).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }

    _expenses.removeAt(index);
    await _budgetService.saveExpenseList(_expenses);

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

                  _expenses[index] = Expense(title: updatedTitle, amount: updatedAmount, uuid: expense.uuid);
                  await _budgetService.saveExpenseList(_expenses);

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

  void _showBudgetEditDialog() {
    final TextEditingController _budgetController =
    TextEditingController(text: _budget.toString());

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Edit Budget'),
          content: TextField(
            controller: _budgetController,
            decoration: InputDecoration(labelText: 'Total Budget'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () async {
                double? newBudget = double.tryParse(_budgetController.text);
                if (newBudget != null && newBudget >= 0) {
                  await _budgetService.saveBudget(newBudget);
                  setState(() {
                    _budget = newBudget;
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddExpenseModal,
          ),
        ],
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: _showBudgetEditDialog,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Your Budget', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(
                    'RM${(_budget - _expenses.fold(0, (sum, item) => sum + item.amount)).toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 24, color: Colors.teal),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Total Budget: RM${_budget.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
          Divider(thickness: 1),

          Expanded(
            child: _expenses.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No expenses added yet!', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  if (FirebaseAuth.instance.currentUser == null)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Login()),
                        );
                      },
                      child: Text.rich(
                        TextSpan(
                          text: 'Log in',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: ' to load expense from cloud',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                ],
              ),
            )
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
                        IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteExpense(_expenses, index)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
