import 'package:flutter/material.dart';
import '../screen/login.dart';
import 'personalization.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace this with the actual username from your app's logic
    final String username = "John Doe";

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
              SizedBox(
                width: 250.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PersonalizationPage()),
                    );
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => Login()),
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