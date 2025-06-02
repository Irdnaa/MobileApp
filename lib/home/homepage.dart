import 'package:flutter/material.dart';
import '../budget_setup_page.dart';
import '../screen/login.dart';
import 'personalization.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String username = "John Doe";

    return Scaffold(
      appBar: AppBar(title: const Text('Home Page'), centerTitle: true),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center, // <--- Add this
          // mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Text(
                'Hello, $username',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 250.0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PersonalizationPage()),
                  );
                },
                child: const Text('Go to Personalization'),
              ),
            ),
            SizedBox(
              width: 250.0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BudgetSetupPage()),
                  );
                },
                child: const Text('Budget Setup'),
              ),
            ),
            SizedBox(
              width: 250.0,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Logout successful!')),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Login()),
                  );
                },
                child: const Text('Logout'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
