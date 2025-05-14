import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  Map userData = {};
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
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
                                // validator: ((value) {
                                //   if (value == null || value.isEmpty) {
                                //     return 'please enter some text';
                                //   } else if (value.length < 5) {
                                //     return 'Enter atleast 5 Charecter';
                                //   }

                                //   return null;
                                // }),
                                validator: MultiValidator([
                                  RequiredValidator(errorText: 'Enter first name'),
                                  MinLengthValidator(3,
                                      errorText: 'First name should be at least 3 character'),
                                ]).call,

                                decoration: InputDecoration(
                                    hintText: 'Enter first name',
                                    labelText: 'First Name',
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: Colors.green,
                                    ),
                                    errorStyle: TextStyle(fontSize: 18.0),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.red),
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(9.0)))),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                validator: MultiValidator([
                                  RequiredValidator(errorText: 'Enter last name'),
                                  MinLengthValidator(3,
                                      errorText:
                                      'Last name should be at least 3 character'),
                                ]).call,
                                decoration: InputDecoration(
                                    hintText: 'Enter last name',
                                    labelText: 'Last Name',
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                    ),
                                    errorStyle: TextStyle(fontSize: 18.0),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.red),
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(9.0)))),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
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
                                    errorStyle: TextStyle(fontSize: 18.0),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.red),
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(9.0)))),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
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
                                    errorStyle: TextStyle(fontSize: 18.0),
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
                                          onPressed: () {
                                            if (_formkey.currentState!.validate()) {
                                              Navigator.pushNamed(context, '/');
                                            }
                                          },
                                          child: Text(
                                            'Register',
                                            style: TextStyle(color: Colors.white, fontSize: 22),
                                          )),
                                      ),
                                      SizedBox(
                                        width: 150.0,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            )
                                          ),
                                          onPressed: () {
                                              Navigator.pushNamed(context, '/');
                                          },
                                          child: Text(
                                            'Sign In',
                                            style: TextStyle(color: Colors.white, fontSize: 22),
                                          )),
                                      )
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