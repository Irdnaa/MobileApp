import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import '../service/auth_service.dart';
import 'package:uuid/uuid.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  Map userData = {};
  final _formkey = GlobalKey<FormState>();
  final authService = AuthService();

  String _password = '';
  String _email = '';
  String _name = '';
  String _phone = '';
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                    key: _formkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 20.0),
                        //   child: Center(
                        //     child: Container(
                        //       width: 200,
                        //       height: 150,
                        //       //decoration: BoxDecoration(
                        //       //borderRadius: BorderRadius.circular(40),
                        //       //border: Border.all(color: Colors.blueGrey)),
                        //       child: Image.asset('assets/logo.png'),
                        //     ),
                        //   ),
                        // ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextFormField(
                                onChanged: (val) => _name = val,
                                validator: MultiValidator([
                                  RequiredValidator(errorText: 'Enter name'),
                                  MinLengthValidator(3,
                                      errorText: 'Name should be at least 2 character'),
                                ]).call,

                                decoration: InputDecoration(
                                    hintText: 'Enter name',
                                    labelText: 'Name',
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: Colors.green,
                                    ),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.red),
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(9.0)))),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                onChanged: (val) => _email = val,
                                validator: MultiValidator([
                                  RequiredValidator(errorText: 'Enter email address'),
                                  EmailValidator(
                                      errorText: 'Invalid email address'),
                                ]).call,
                                decoration: InputDecoration(
                                    hintText: 'Email',
                                    labelText: 'Email',
                                    prefixIcon: Icon(
                                      Icons.email,
                                      color: Colors.lightBlue,
                                    ),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.red),
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(9.0)))),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                onChanged: (val) => _phone = val,
                                validator: ((value) {
                                  RegExp regex = RegExp(r'(^(?:[+0]9)?[0-9]{10}$)');

                                  if (value == null || value.isEmpty) {
                                    return 'Enter phone number';
                                  } else if (!regex.hasMatch(value)) {
                                    return 'Invalid phone number';
                                  }

                                  return null;
                                }),
                                decoration: InputDecoration(
                                    hintText: 'Mobile',
                                    labelText: 'Mobile',
                                    prefixIcon: Icon(
                                      Icons.phone,
                                      color: Colors.grey,
                                    ),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.red),
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(9)))),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                obscureText: _obscureText,
                                onChanged: (val) => _password = val,
                                validator: MultiValidator([
                                  RequiredValidator(errorText: 'Enter password'),
                                  MinLengthValidator(6, errorText: 'Password must be at least 6 digits long'),
                                  //PatternValidator(r'(?=.*?[#?!@$%^&*-])', errorText: 'Password must have at least one special character')
                                ]).call,
                                decoration: InputDecoration(
                                    hintText: 'Password',
                                    labelText: 'Password',
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: Colors.grey,
                                    ),
                                    suffixIcon: Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _obscureText = !_obscureText;
                                            });
                                          },
                                          icon: Icon(
                                            _obscureText ? Icons.visibility : Icons.visibility_off_rounded
                                          ),
                                          color: Colors.grey,
                                        ),
                                    ),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.red),
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(9)))),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                obscureText: _obscureText,
                                validator: (val) => MatchValidator(errorText: 'Passwords do not match').validateMatch(val!, _password),
                                decoration: InputDecoration(
                                    hintText: 'Confirm password',
                                    labelText: 'Confirm password',
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: Colors.grey,
                                    ),
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                                      child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                        icon: Icon(
                                          _obscureText ? Icons.visibility : Icons.visibility_off_rounded
                                        ),
                                        color: Colors.grey,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.red),
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(9)))),
                              ),
                            ),
                            Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Column(
                                    // margin: EdgeInsets.fromLTRB(200, 20, 50, 0),
                                    // width: MediaQuery.of(context).size.width,
                                    //
                                    // height: 50,
                                    // margin: EdgeInsets.fromLTRB(200, 20, 50, 0),
                                    children: <Widget>[
                                      SizedBox(
                                        width: 150.0,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            )
                                          ),
                                          onPressed: () async {
                                            if (_formkey.currentState!.validate()) {
                                              try {
                                                authService.createAccount( _email, _password);
                                                String uid = Uuid().v4();
                                                await FirebaseFirestore.instance.collection('users').doc(uid).set({
                                                'email': _email,
                                                'name': _name,
                                                'phone': _phone,
                                                'uid': uid,
                                                'timestamp': FieldValue.serverTimestamp(),
                                                });

                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('✅ Register successful!')),
                                                );
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (_) => const Login()),
                                                );
                                              } on FirebaseAuthException catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(e.message ?? 'Registration failed')),
                                                );
                                              }
                                            }
                                          },
                                          child: Text(
                                            'Register',
                                            style: TextStyle(color: Colors.white, fontSize: 22),
                                          )),
                                      ),
                                      const SizedBox(height: 20),
                                      GestureDetector(
                                        onTap: () {

                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (_) => const Login()),
                                          );
                                        },
                                        child: const Text(
                                          'Sign In',
                                          style: TextStyle(
                                            decoration: TextDecoration.underline,
                                            color: Colors.blueAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ]
                                  ),
                                )
                            ),
                      ],
                    )),
              ),
            )
          ),
        ),
      )
    );
  }
}