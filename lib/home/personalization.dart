import 'package:flutter/material.dart';
import 'homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../service/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

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

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();


  @override
  void initState() {
    super.initState();
    nameController.text = widget.user.name;
    phoneController.text = widget.user.phone;
  }

  Uint8List? _image;
  void selectImage() async{
    Uint8List? img= await pickImage(ImageSource.gallery);

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
            Card(
              margin: EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text('User Information'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundImage: AssetImage('assets/images/profileDefault.jpg'),
                    ),
                    TextField(
                      controller: TextEditingController(text: widget.user.email),
                      readOnly: true,
                      style: TextStyle(color: Colors.grey), // Grey text
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email, color: const Color.fromARGB(255, 73, 71, 71)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9.0)),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200, // Light grey background
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person, color: Colors.green),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9.0)),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9.0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).update({
                    'name': nameController.text,
                    'phone': phoneController.text,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Profile updated!")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to update: $e")),
                  );
                }
              },
              icon: Icon(Icons.save),
              label: Text("Update Profile"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
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

            SizedBox(height: 20),

           

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
