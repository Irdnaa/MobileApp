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
  final String uid;

  AppUser({required this.email, required this.name, required this.phone, required this.uid});

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      uid: data['uid'] ?? '',
    );
  }
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid =user?.uid;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text('No user logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
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

          return Center(
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
                Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text('User Information'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${appUser.email}'),
                        Text('Name: ${appUser.name}'),
                        Text('Phone: ${appUser.phone}'),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 250.0,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PersonalizationPage(user: appUser),
                        ),
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
          );
        },
      ),
    );
  }
}