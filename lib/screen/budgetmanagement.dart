import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../model/expense.dart';
import '../service/budget_service.dart';
import '../service/currency_input.dart';
import 'login.dart';

class ExpenseHomePage extends StatefulWidget {
  @override
  _ExpenseHomePageState createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  late BudgetService _budgetService;
  List<Expense> _expenses = [];
  double _budget = 0.0;
  bool _exceeded = false;

  double get _dailyBudget => _budget / 30;

  @override
  void initState() {
    super.initState();
    _budgetService = BudgetService(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    );
    _loadExpenses();
    _loadBudget();
  }

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  Future<void> _loadBudget() async {
    double loaded = await _budgetService.loadBudget();
    setState(() {
      _budget = loaded;
    });
    _checkExceeded();
  }

  void _checkExceeded() {
    if (_todayExpenseTotal > _dailyBudget) {
      _exceeded = true;
    } else {
      _exceeded = false;
    }
    setState(() {});
  }
  
  void _showDailyBudgetExceededDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Budget Alert'),
        content: Text('You have exceeded your daily budget of RM${_dailyBudget.toStringAsFixed(2)}.'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  double get _todayExpenseTotal {
    final now = DateTime.now();
    return _expenses
        .where((e) {
      final timestamp = e.timestamp; // You'll need to add this field
      return timestamp.year == now.year &&
          timestamp.month == now.month &&
          timestamp.day == now.day;
    })
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Future<void> _loadExpenses() async {
    List<Expense> loaded = await _budgetService.loadExpenseList();
    setState(() {
      _expenses = loaded;
    });
    _checkExceeded();
  }

  void _addExpense() async {
    List<Expense> newExpenses = [];
    String title = _titleController.text;
    String rawAmount = _amountController.text.replaceAll(',', '');
    double? amount = double.tryParse(rawAmount);
    String uuid = Uuid().v4();
    DateTime timestamp = DateTime.now();

    if (title.isEmpty || amount == null || amount <= 0) return;

    _expenses.add(Expense(title: title, amount: amount, uuid: uuid, timestamp: timestamp));
    newExpenses.clear();
    newExpenses.add(Expense(title: title, amount: amount, uuid: uuid, timestamp: timestamp));
    await _budgetService.saveExpenseList(newExpenses);

    setState(() {});

    _titleController.clear();
    _amountController.clear();

    Navigator.of(context).pop();

    if (_exceeded == false) {
      if (_todayExpenseTotal > _dailyBudget) {
        _exceeded = true;
        setState(() {});
        _showDailyBudgetExceededDialog();
      }
    }
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

    if (_exceeded == true) {
      if (_todayExpenseTotal < _dailyBudget) {
        _exceeded = false;
      }
    }

    setState(() {});
  }

  void _editExpense(int index) async {
    final expense = _expenses[index];
    _titleController.text = expense.title;
    _amountController.text = expense.amount.toStringAsFixed(2);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  inputFormatters: [CurrencyInputFormatter()],
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
                    final raw = _amountController.text.replaceAll(',', '');
                    double? updatedAmount = double.tryParse(raw);

                    if (updatedTitle.isEmpty || updatedAmount == null || updatedAmount <= 0) return;

                    _expenses[index] = Expense(
                      title: updatedTitle,
                      amount: updatedAmount,
                      uuid: expense.uuid,
                      timestamp: expense.timestamp,
                    );
                    await _budgetService.saveExpenseList(_expenses);
                    setState(() {});
                    _titleController.clear();
                    _amountController.clear();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddExpenseModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // This allows the modal to expand when the keyboard appears
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min, // Shrinks to fit content
              children: [
                Text(
                  'Add New Expense',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Expense'),
                ),
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(12),
                    backgroundColor: Colors.teal,
                  ),
                  onPressed: _addExpense,
                  child: Text('Add Expense'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBudgetEditDialog() {
    final TextEditingController _budgetController = TextEditingController(text: _budget.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Edit Budget'),
          content: TextField(
            controller: _budgetController,
            inputFormatters: [CurrencyInputFormatter()],
            decoration: InputDecoration(labelText: 'Total Budget'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () async {
                final raw = _budgetController.text.replaceAll(',', '');
                double? newBudget = double.tryParse(raw);
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'RM${(_budget - _expenses.fold(0, (sum, item) => sum + item.amount)).toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 24, color: Colors.teal),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.edit, size: 20, color: Colors.teal),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Daily Budget: RM${(_dailyBudget - _todayExpenseTotal).toStringAsFixed(2)}',
                    style: _exceeded
                      ? TextStyle(fontSize: 14, color: Colors.red)
                      : TextStyle(fontSize: 14, color: Colors.grey[600])
                  ),
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
