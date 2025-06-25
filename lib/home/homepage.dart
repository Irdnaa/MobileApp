import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/screen/budgetmanagement.dart';
import '../screen/login.dart';
import '../service/auth_service.dart';
import '../service/budget_service.dart';
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
    final budgetService = BudgetService(auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance);

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
          body: FutureBuilder(
            future: budgetService.generateBudgetTrendPoints(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final graphData = snapshot.data as List<FlSpot>;
              final minY = graphData.isNotEmpty
                  ? graphData.map((e) => e.y).reduce((a, b) => a < b ? a : b)
                  : 0.0;

              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Budget Balance Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0), // Adjust as needed
                    child: SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          minY: minY < 0 ? minY : 0,
                          lineBarsData: [
                            LineChartBarData(
                              spots: graphData,
                              color: graphData.isNotEmpty && graphData.last.y < 0 ? Colors.red : Colors.green,
                              barWidth: 2,
                              belowBarData: BarAreaData(
                                show: true,
                                color: (graphData.isNotEmpty && graphData.last.y < 0)
                                    ? const Color.fromRGBO(255, 0, 0, 0.3)
                                    : const Color.fromRGBO(0, 128, 0, 0.3),
                              ),
                            )
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 48, // Increase this for more space (default is 40)
                                getTitlesWidget: (value, meta) => Text(
                                  value.toStringAsFixed(0),
                                  style: const TextStyle(fontSize: 12), // Smaller font
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
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
              );
            },
          ),

        );
      },
    );
  }
}