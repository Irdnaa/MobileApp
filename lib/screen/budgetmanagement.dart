import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'login.dart';

class ExpenseApp extends StatefulWidget {
  const ExpenseApp({super.key});

  @override
  _ExpenseHomePageState createState() => _ExpenseHomePageState();
}

class Expense {
  String title;
  double amount;
  String uuid;

  Expense({required this.title, required this.amount, required this.uuid});

  factory Expense.fromJson(Map<String, dynamic> json) {
    final data = json['expense_list'] as Map<String, dynamic>;
    return Expense(
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      uuid: data['uuid'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'uuid': uuid
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
    if (FirebaseAuth.instance.currentUser != null) {
      for (var expense in expenses) {
        await FirebaseFirestore.instance.collection('expenses').doc(expense.uuid).set({
          'expense_list': expense.toJson(),
          'uid': FirebaseAuth.instance.currentUser?.uid,
        });
      }
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> jsonStringList = expenses.map((expense) => jsonEncode(expense.toJson())).toList();
      await prefs.setStringList('expense_list', jsonStringList);
    }
  }

  Future<void> loadExpenseList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonStringList = prefs.getStringList('expense_list');
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('expenses').where('uid', isEqualTo: uid).get();

      List<Expense> firebaseExpenses = snapshot.docs.map((doc) => Expense.fromJson(doc.data() as Map<String, dynamic>)).toList();

      setState(() {
        _expenses = firebaseExpenses;
      });

      // List<String> jsonStringList = firebaseExpenses.map((e) => jsonEncode(e.toJson())).toList();
      // await prefs.setStringList('expense_list', jsonStringList);
    } else if (jsonStringList != null) {
      setState(() {
        _expenses = jsonStringList.map((jsonString) => Expense.fromJson(jsonDecode(jsonString))).toList();
      });
    }
  }

  void _addExpense() async {
    String title = _titleController.text;
    double? amount = double.tryParse(_amountController.text);
    String uuid = Uuid().v4();

    if (title.isEmpty || amount == null || amount <= 0) return;

    _expenses.clear();
    _expenses.add(Expense(title: title, amount: amount, uuid: uuid));
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

                  _expenses[index] = Expense(title: updatedTitle, amount: updatedAmount, uuid: expense.uuid);
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No expenses added yet!',style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10,),
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
                              )
                            )
                          ]
                        )
                      ),
                    )
                ],
              )
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
