import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../service/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

String? profileImageUrl;

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
  final _formKey = GlobalKey<FormState>();
  bool isEditing = false;
  String? imageDocId;
  Uint8List? _newProfileImageBytes;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.user.name;
    phoneController.text = widget.user.phone;
    imageDocId = widget.user.profileImageDocId;
  }

  Future<String?> uploadUserImageAsBlob(Uint8List imageBytes, String userId) async {
    // Save image as a separate document
    final imageDoc = await FirebaseFirestore.instance.collection('user_images').add({
      'userId': userId,
      'imageBlob': imageBytes,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
    // Return the image document ID
    return imageDoc.id;
  }

  Future<ImageProvider?> getUserProfileImage(String? imageDocId) async {
    print('1');
    if (imageDocId == null) return null;
    print('2');
    final doc = await FirebaseFirestore.instance.collection('user_images').doc(imageDocId).get();
    print('doc data: ${doc.data()}');
    if (doc.exists && doc.data()?['imageBlob'] != null) {
      final blob = doc.data()!['imageBlob'];
      Uint8List bytes;
      if (blob is Blob) {
        bytes = blob.bytes;
      } else if (blob is Uint8List) {
        bytes = blob;
      } else if (blob is List) {
        bytes = Uint8List.fromList(List<int>.from(blob));
      } else {
        print('imageBlob is not a Blob, Uint8List, or List');
        return null;
      }
      print('4');
      print(bytes.length);
      return MemoryImage(bytes);
    }
    print('3');
    return null;
  }

// Future<void> uploadProfileImage(File imageFile) async {
//   final user = widget.user;
//   final storageRef = FirebaseStorage.instance
//       .ref()
//       .child('profile_pictures')
//       .child('${user.uid}.jpg');

//   try {
//     final uploadTask = await storageRef.putFile(imageFile);
//     if (uploadTask.state == TaskState.success) {
//       final downloadUrl = await storageRef.getDownloadURL();
//       await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
//         'profileImageUrl': downloadUrl,
//       });
//       setState(() {
//         profileImageUrl = downloadUrl;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Profile picture updated!")),
//       );
//     } else {
//       throw Exception('Upload failed');
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Image upload failed: $e")),
//     );
//   }
// }

  void selectImageFromGallery() async {
    Uint8List? imgBytes = await pickImageBytes(ImageSource.gallery);
    if (imgBytes != null) {
      imgBytes = await compressImage(imgBytes);
      setState(() {
        _newProfileImageBytes = imgBytes;
      });
    }
  }

  void selectImageFromCamera() async {
    Uint8List? imgBytes = await pickImageBytes(ImageSource.camera);
    if (imgBytes != null) {
      imgBytes = await compressImage(imgBytes);
      setState(() {
        _newProfileImageBytes = imgBytes;
      });
    }
  }

  Future<Uint8List?> compressImage(Uint8List imageBytes) async {
    return await FlutterImageCompress.compressWithList(
      imageBytes,
      minWidth: 256,
      minHeight: 256,
      quality: 70,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Personalization"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (FirebaseAuth.instance.currentUser != null)
            Card(
              margin: EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('User Information'),
                    IconButton(
                      icon: Icon(isEditing ? Icons.close : Icons.edit),
                      onPressed: () {
                        setState(() {
                          isEditing = !isEditing;
                          // Reset fields if cancel edit
                          if (!isEditing) {
                            nameController.text = widget.user.name;
                            phoneController.text = widget.user.phone;
                          }
                        });
                      },
                    ),
                  ],
                ),
                subtitle: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          _newProfileImageBytes != null
                              ? CircleAvatar(
                                  radius: 64,
                                  backgroundImage: MemoryImage(_newProfileImageBytes!),
                                )
                              : (imageDocId != null
                                  ? FutureBuilder<ImageProvider?>(
                                      future: getUserProfileImage(imageDocId),
                                      builder: (context, snapshot) {
                                        print(imageDocId);
                                        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                                          return CircleAvatar(
                                            radius: 64,
                                            backgroundImage: snapshot.data!,
                                          );
                                        }
                                        // While loading or if error, show default
                                        return CircleAvatar(
                                          radius: 64,
                                          backgroundImage: AssetImage('assets/images/profileDefault.jpg'),
                                        );
                                      },
                                    )
                                  : CircleAvatar(
                                      radius: 64,
                                      backgroundImage: AssetImage('assets/images/profileDefault.jpg'),
                                    )),
                          if (isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.photo_camera),
                                    onPressed: selectImageFromCamera,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.photo_library),
                                    onPressed: selectImageFromGallery,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      TextField(
                        controller: TextEditingController(text: widget.user.email),
                        readOnly: true,
                        style: TextStyle(color: Colors.grey),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email, color: Color.fromARGB(255, 73, 71, 71)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(9.0)),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: nameController,
                        enabled: isEditing,
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Enter name'),
                          MinLengthValidator(3, errorText: 'Name should be at least 2 characters'),
                        ]).call,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person, color: Colors.green),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(9.0)),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: phoneController,
                        enabled: isEditing,
                        validator: (value) {
                          RegExp regex = RegExp(r'(^(?:[+0]9)?[0-9]{10}$)');
                          if (value == null || value.isEmpty) {
                            return 'Enter phone number';
                          } else if (!regex.hasMatch(value)) {
                            return 'Invalid phone number';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icon(Icons.phone, color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(9.0)),
                          ),
                        ),
                      ),
                      if (isEditing)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  // Upload the new image if there is one
                                  if (_newProfileImageBytes != null) {
                                    String? newDocId = await uploadUserImageAsBlob(_newProfileImageBytes!, widget.user.uid);
                                    if (newDocId != null) {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.user.uid)
                                          .update({'profileImageDocId': newDocId});
                                      setState(() {
                                        imageDocId = newDocId;
                                      });
                                    }
                                    _newProfileImageBytes = null; // Reset after upload
                                  }
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.user.uid)
                                      .update({
                                    'name': nameController.text,
                                    'phone': phoneController.text,
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Profile updated!")),
                                  );
                                  setState(() {
                                    isEditing = false;
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Failed to update: $e")),
                                  );
                                }
                              }
                            },
                            icon: Icon(Icons.save),
                            label: Text("Save"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 40),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            
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
            ),
            
          ],
        ),
      ),
    );
  }
}
