import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../model/expense.dart';
import '../service/budget_service.dart';
import '../widgets/budget_summary_card.dart';
import '../widgets/custom_input_dialog.dart';
import '../widgets/expense_form_bottom_sheet.dart';
import '../widgets/expense_list_view.dart';
import '../widgets/simple_alert_dialog.dart';

class ExpenseHomePage extends StatefulWidget {
  @override
  _ExpenseHomePageState createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  late BudgetService _budgetService;
  List<Expense> _expenses = [];
  double _budget = 0.0;
  bool _exceeded = false;
  double _savingsGoal = 0.0;
  bool _goalReached = false;

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
    _loadSavingsGoal();
  }

  Future<void> _loadSavingsGoal() async {
    double goal = await _budgetService.loadSavingsGoal();
    setState(() {
      _savingsGoal = goal;
    });
    _checkSavingsGoal();
  }

  void _checkSavingsGoal() {
    final reached = _budgetService.hasReachedSavingsGoal(_budget, _savingsGoal, _expenses);

    if (reached && !_goalReached) {
      _goalReached = true;
      _showSavingsGoalReachedDialog();
    } else if (!reached) {
      _goalReached = false;
    }
  }

  void _showSavingsGoalReachedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('🎉 Goal Reached!'),
        content: Text('Congratulations! You have saved RM${_savingsGoal.toStringAsFixed(2)}.'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showSavingsGoalDialog() {
    showDialog(
      context: context,
      builder: (_) => CustomInputDialog(
        title: 'Set Savings Goal',
        labelText: 'Savings Goal Amount',
        initialValue: _savingsGoal.toStringAsFixed(2),
        onSubmitted: (value) async {
          await _budgetService.saveSavingsGoal(value);
          setState(() {
            _savingsGoal = value;
          });
          _checkSavingsGoal();
        },
      ),
    );
  }

  Future<void> _loadBudget() async {
    double loaded = await _budgetService.loadBudget();
    setState(() {
      _budget = loaded;
    });
    _checkExceeded();
    _checkSavingsGoal();
  }

  void _checkExceeded() {
    _exceeded = _budgetService.hasExceededDailyBudget(_budget, _expenses);
    setState(() {});
  }

  void _showDailyBudgetExceededDialog() {
    showDialog(
      context: context,
      builder: (_) => SimpleAlertDialog(
        title: 'Budget Alert',
        message: 'You have exceeded your daily budget of RM${_dailyBudget.toStringAsFixed(2)}.',
      ),
    );
  }

  double get _todayExpenseTotal => _budgetService.calculateTodayExpenseTotal(_expenses);

  Future<void> _loadExpenses() async {
    List<Expense> loaded = await _budgetService.loadExpenseList();
    setState(() {
      _expenses = loaded;
    });
    _checkExceeded();
    _checkSavingsGoal();
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
    _checkSavingsGoal();
  }

  void _editExpense(int index) {
    final expense = _expenses[index];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ExpenseFormBottomSheet(
        title: 'Edit Expense',
        initialExpense: expense,
        onSubmit: (title, amount) async {
          _expenses[index] = Expense(
            title: title,
            amount: amount,
            uuid: expense.uuid,
            timestamp: expense.timestamp,
          );
          await _budgetService.saveExpenseList(_expenses);
          setState(() {});
          _checkSavingsGoal();
        },
      ),
    );
  }

  void _showAddExpenseModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ExpenseFormBottomSheet(
        title: 'Add New Expense',
        onSubmit: (title, amount) async {
          final uuid = Uuid().v4();
          final timestamp = DateTime.now();
          final newExpense = Expense(title: title, amount: amount, uuid: uuid, timestamp: timestamp);

          _expenses.add(newExpense);
          await _budgetService.saveExpenseList([newExpense]);

          setState(() {});
          _checkSavingsGoal();

          if (!_exceeded && _todayExpenseTotal > _dailyBudget) {
            _exceeded = true;
            _showDailyBudgetExceededDialog();
          }
        },
      ),
    );
  }

  void _showBudgetEditDialog() {
    showDialog(
      context: context,
      builder: (_) => CustomInputDialog(
        title: 'Edit Budget',
        labelText: 'Total Budget',
        initialValue: _budget.toStringAsFixed(2),
        onSubmitted: (value) async {
          await _budgetService.saveBudget(value);
          setState(() {
            _budget = value;
          });
        },
      ),
    );
  }

  void _repeatExpense(Expense expense) async {
    final repeated = Expense(
      title: expense.title,
      amount: expense.amount,
      uuid: Uuid().v4(), // New UUID
      timestamp: DateTime.now(), // New timestamp
    );

    _expenses.add(repeated);
    await _budgetService.saveExpenseList([repeated]);

    setState(() {});

    if (!_exceeded && _todayExpenseTotal > _dailyBudget) {
      _exceeded = true;
      _showDailyBudgetExceededDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              await _budgetService.generateMonthlyExpensePdf(_expenses);
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddExpenseModal,
          ),
        ],
      ),
      body: Column(
        children: [
          BudgetSummaryCard(
            budget: _budget,
            expenses: _expenses,
            exceeded: _exceeded,
            dailyBudget: _dailyBudget,
            onEditBudget: _showBudgetEditDialog,
            onSetGoal: _showSavingsGoalDialog,
          ),
          Divider(thickness: 1),

          Expanded(
            child: ExpenseListView(
              expenses: _expenses,
              onEdit: _editExpense,
              onDelete: _deleteExpense,
              onRepeat: _repeatExpense,
            ),
          )

        ],
      ),
    );
  }
}
