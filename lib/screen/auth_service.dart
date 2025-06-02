import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

ValueNotifier<AuthService> authService = ValueNotifier<AuthService>(AuthService());
class AuthService{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

 User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get userChanges => firebaseAuth.userChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
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
