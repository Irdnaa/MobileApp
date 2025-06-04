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

class AppUser {
  final String email;
  final String name;
  final String phone;

  AppUser({required this.email, required this.name, required this.phone});

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
    );
  }
}

class _HomePageState extends State<HomePage> {
  AppUser? appUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final email = user.email;
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();
      setState(() {
        appUser = AppUser.fromMap(data);
        isLoading = false;
      });
    } else {
      setState(() {
        appUser = null;
        isLoading = false;
      });
    }
  } else {
    setState(() {
      appUser = null;
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
                        (appUser == null || appUser!.name.isEmpty)
                            ? 'Hello'
                            : 'Hello, ${appUser!.name}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            SizedBox(
              width: 250.0,
              child: ElevatedButton(
                onPressed: () {
                  if (appUser != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PersonalizationPage(user: appUser!),
                      ),
                    );
                  }
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