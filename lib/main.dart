import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'budget_setup_page.dart';
import 'firebase_options.dart'; // ✅ Make sure this import exists

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    print("Firebase initialization error: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Budget Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BudgetSetupPage(), // The budget page
    );
  }
}
