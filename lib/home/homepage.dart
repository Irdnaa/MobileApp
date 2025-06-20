import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/screen/budgetmanagement.dart';
import '../service/auth_service.dart';
import '../screen/login.dart';
import 'personalization.dart';
import '../model/app_user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Guest view
      return Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(25.0),
                child: Text(
                  'Welcome, Guest!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              SizedBox(
                width: 250.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => Login()),
                    );
                  },
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Authenticated user view
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print(user.email);
          return const Center(child: Text('User not found.'));
        }
        final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final appUser = AppUser.fromMap(data);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Home Page'),
            actions: [
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PersonalizationPage(user: appUser),
                    ),
                  );
                },
              ),
            ],
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Text(
                    (appUser.name.isEmpty)
                        ? 'Hello'
                        : 'Hello, ${appUser.name}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
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
              ],
            ),
          ),
        );
      },
    );
  }
}