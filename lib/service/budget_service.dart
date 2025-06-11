import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/expense.dart';

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
}
