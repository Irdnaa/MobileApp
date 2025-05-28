import 'package:flutter/material.dart';

class PersonalizationPage extends StatefulWidget {
  final bool budgetPlanningEnabled;
  const PersonalizationPage({super.key, this.budgetPlanningEnabled = true});

  @override
  _PersonalizationPageState createState() => _PersonalizationPageState();
}

class _PersonalizationPageState extends State<PersonalizationPage> {
  late bool budgetPlanningEnabled;
  bool savingTipsEnabled = true;
  bool spendingTrackerEnabled = true;

  @override
  void initState() {
    super.initState();
    budgetPlanningEnabled = widget.budgetPlanningEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Personalization"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Customize your dashboard",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Budget Planning Toggle
            SwitchListTile(
              title: Text("Budget Planning"),
              subtitle: Text("Track and plan your monthly budget"),
              value: budgetPlanningEnabled,
              onChanged: (val) {
                setState(() {
                  budgetPlanningEnabled = val;
                });
              },
            ),

            // Saving Tips Toggle
            SwitchListTile(
              title: Text("Saving Tips"),
              subtitle: Text("Get tips to help you save better"),
              value: savingTipsEnabled,
              onChanged: (val) {
                setState(() {
                  savingTipsEnabled = val;
                });
              },
            ),

            // Spending Tracker Toggle
            SwitchListTile(
              title: Text("Spending Tracker"),
              subtitle: Text("Monitor your daily expenses"),
              value: spendingTrackerEnabled,
              onChanged: (val) {
                setState(() {
                  spendingTrackerEnabled = val;
                });
              },
            ),

            SizedBox(height: 30),

            // Save Button
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Preferences saved")),
                );
                // Return the updated budgetPlanningEnabled value to HomePage
                Navigator.pop(context, budgetPlanningEnabled);
              },
              icon: Icon(Icons.save),
              label: Text("Save Preferences"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            )
          ],
        ),
      ),
    );
  }
}
