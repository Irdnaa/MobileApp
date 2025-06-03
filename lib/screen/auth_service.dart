import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

ValueNotifier<AuthService> authService = ValueNotifier<AuthService>(AuthService());
class AuthService{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

 User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get userChanges => firebaseAuth.userChanges();

  Future signIn(String email, String password) async {
    await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future createAccount(String email, String password, String name, String phoneNumber) async {
    final UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> addUserDetails(String name, String phone, String email) async {
    await FirebaseFirestore.instance.collection('users').add({
      'name': name,
      'phone': phone,
      'email': email,
    });
  }

  Future<void> signOut() async {
    return await firebaseAuth.signOut();
  }
  Future<void> sendPasswordResetEmail(String email) async {
    return await firebaseAuth.sendPasswordResetEmail(email: email);
  }
  Future<void> updateUsername(String username) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      await user.updateProfile(displayName: username);
      await user.reload();
    }
  }
  Future<void> deleteAccount({
    required String username,
    required String password,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: username,
      password: password,
    );
    await firebaseAuth.currentUser?.reauthenticateWithCredential(credential);
    await firebaseAuth.currentUser?.delete(); 
    await firebaseAuth.signOut();
  }

  Future<void> resetPasswrodFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await firebaseAuth.currentUser?.reauthenticateWithCredential(credential);
    await firebaseAuth.currentUser?.updatePassword(newPassword);
    }
  }
