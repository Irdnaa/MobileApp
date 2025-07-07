import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/expense.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BudgetService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  BudgetService({required this.auth, required this.firestore});

  Future<void> saveExpenseList(List<Expense> expenses) async {
    final user = auth.currentUser;

    if (user != null) {
      for (var expense in expenses) {
        await firestore.collection('expenses').doc(expense.uuid).set({
          'expense_list': expense.toJson(),
          'uid': user.uid,
        });
      }
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> jsonStringList = expenses.map((expense) {
        final data = {
          'expense_list': expense.toJson(),
          'uid': 'guest', // 👈 Insert guest UID for local data
        };
        return jsonEncode(data);
      }).toList();
      await prefs.setStringList('expense_list', jsonStringList);
    }
  }

  Future<List<Expense>> loadExpenseList() async {
    final user = auth.currentUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (user != null) {
      QuerySnapshot snapshot = await firestore.collection('expenses').where('uid', isEqualTo: user.uid).get();

      return snapshot.docs.map((doc) {
        return Expense.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } else {
      List<String>? jsonStringList = prefs.getStringList('expense_list');
      if (jsonStringList != null) {
        return jsonStringList.map((jsonString) {
          return Expense.fromJson(jsonDecode(jsonString));
        }).toList();
      } else {
        return [];
      }
    }
  }

  Future<void> saveBudget(double value) async {
    final user = auth.currentUser;

    if (user != null) {
      await firestore.collection('total_budget').doc(user.uid).set({
        'budget': value
      });
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('total_budget', value);
    }
  }

  Future<double> loadBudget() async {
    final user = auth.currentUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (user != null) {
      final doc = await firestore.collection('total_budget').doc(user.uid).get();
      final data = doc.data();
      double budget = (data?['budget'] ?? 0).toDouble();

      return budget;
    } else {
      return prefs.getDouble('total_budget') ?? 0.0;
    }
  }

  Future<List<FlSpot>> generateBudgetTrendPoints() async {
    final user = auth.currentUser;
    if (user == null) return [];

    final totalBudget = await loadBudget();
    final dailyBudget = totalBudget / 30;

    final expenses = await loadExpenseList();

    // Group expenses by day
    final Map<String, double> dailySpending = {};
    for (final e in expenses) {
      final day = DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
      final key = day.toIso8601String();
      dailySpending[key] = (dailySpending[key] ?? 0) + e.amount;
    }

    print('🧾 Daily Spending:');
    dailySpending.forEach((key, value) {
      print('$key: RM${value.toStringAsFixed(2)}');
    });

    final sortedKeys = dailySpending.keys.toList()..sort();
    double cumulative = 0;
    List<FlSpot> points = [];

    for (int i = 0; i < sortedKeys.length; i++) {
      final dateKey = sortedKeys[i];
      final spent = dailySpending[dateKey]!;
      cumulative += dailyBudget - spent;
      final point = FlSpot(i.toDouble(), cumulative);
      points.add(point);
    }

    print('\n📈 FlSpot Points:');
    for (final p in points) {
      print('x: ${p.x}, y: ${p.y}');
    }

    return points;
  }


  Future<void> generateMonthlyExpensePdf(List<Expense> expenses) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    final currentMonthExpenses = expenses.where((e) =>
    e.timestamp.year == now.year && e.timestamp.month == now.month).toList();

    double total = currentMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Monthly Expense Report - ${now.month}/${now.year}')),
          pw.TableHelper.fromTextArray(
            headers: ['Title', 'Amount (RM)', 'Date'],
            data: currentMonthExpenses.map((e) => [
              e.title,
              e.amount.toStringAsFixed(2),
              "${e.timestamp.day}/${e.timestamp.month}/${e.timestamp.year}"
            ]).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Paragraph(
            text: 'Total Expenses: RM${total.toStringAsFixed(2)}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  Future<void> saveSavingsGoal(double goal) async {
    final user = auth.currentUser;
    final prefs = await SharedPreferences.getInstance();

    if (user != null) {
      await firestore.collection('savings_goal').doc(user.uid).set({
        'goal': goal,
      });
    } else {
      await prefs.setDouble('savings_goal', goal);
    }
  }

  Future<double> loadSavingsGoal() async {
    final user = auth.currentUser;
    final prefs = await SharedPreferences.getInstance();

    if (user != null) {
      final doc = await firestore.collection('savings_goal').doc(user.uid).get();
      return (doc.data()?['goal'] ?? 0).toDouble();
    } else {
      return prefs.getDouble('savings_goal') ?? 0.0;
    }
  }

  double calculateTodayExpenseTotal(List<Expense> expenses) {
    final now = DateTime.now();
    return expenses.where((e) =>
    e.timestamp.year == now.year &&
        e.timestamp.month == now.month &&
        e.timestamp.day == now.day
    ).fold(0.0, (sum, e) => sum + e.amount);
  }

  bool hasExceededDailyBudget(double budget, List<Expense> expenses) {
    double daily = budget / 30;
    return calculateTodayExpenseTotal(expenses) > daily;
  }

  bool hasReachedSavingsGoal(double budget, double savingsGoal, List<Expense> expenses) {
    final savings = budget - expenses.fold(0.0, (sum, e) => sum + e.amount);
    return savings >= savingsGoal && savingsGoal > 0;
  }
}
