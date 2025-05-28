import 'package:flutter/material.dart';
import '../screen/login.dart';
import 'personalization.dart';

class HomePage extends StatelessWidget {
  final bool showBudgetPlanning;
  const HomePage({super.key, this.showBudgetPlanning = false});

  @override
  Widget build(BuildContext context) {
    final String username = " User";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true
      ),
      body: Center(
        child: Column(
            children: [
              Center(
                child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Text(
                      'Hello, $username',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                )
              ),
              if (showBudgetPlanning)
                BudgetPlanningDashboard(),
              SizedBox(
                width: 250.0,
                child: ElevatedButton(
                  onPressed: () async {
                    // Await the result from PersonalizationPage
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PersonalizationPage(
                          budgetPlanningEnabled: showBudgetPlanning,
                        ),
                      ),
                    );
                    // If result is not null, rebuild HomePage with new state
                    if (result != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HomePage(showBudgetPlanning: result),
                        ),
                      );
                    }
                  },
                  child: const Text('Go to Personalization'),
                )
              ),
              SizedBox(
                width: 250.0,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✅ Logout successful!')),
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const Login()),
                      (route) => false,
                    );
                  },
                  child: const Text('Logout'),
                ),
              )
            ]
        ),
      )
    );
  }
}

class BudgetPlanningDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          Text("Budget Planning", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ListTile(title: Text("Foods")),
          ListTile(title: Text("Study Material")),
          ListTile(title: Text("Leisure")),
          ListTile(title: Text("Utilities")),
        ],
      ),
    );
  }
}