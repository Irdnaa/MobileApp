import 'package:flutter/material.dart';
import 'homepage.dart';

class PersonalizationPage extends StatefulWidget {
  final AppUser user;
  const PersonalizationPage({super.key,required this.user});

  @override
  _PersonalizationPageState createState() => _PersonalizationPageState();
}

class _PersonalizationPageState extends State<PersonalizationPage> {
  bool budgetPlanningEnabled = true;
  bool savingTipsEnabled = true;
  bool spendingTrackerEnabled = true;

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

            Text("Profile: ${widget.user.email}\nHello ${widget.user.name}\nHello ${widget.user.phone}",
            
           
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
                // Save preferences logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Preferences saved")),
                );
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
