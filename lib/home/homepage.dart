import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/screen/budgetmanagement.dart';
import '../screen/login.dart';
import 'personalization.dart';
import '../screen/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final email = user.email;
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        setState(() {
          username = query.docs.first['name'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          username = null;
          isLoading = false;
        });
      }
    } else {
      setState(() {
        username = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        (username == null || username!.isEmpty)
                            ? 'Hello'
                            : 'Hello, $username',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
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
              ),
            ),
            SizedBox(
              width: 250.0,
              child: ElevatedButton(
                onPressed: () {
                  AuthService().signOut();
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
            ),
            SizedBox(
              width: 250.0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ExpenseHomePage()),
                  );
                },
                child: const Text('Go to Expenses Management'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}