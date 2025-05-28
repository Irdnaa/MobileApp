// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCeBQtDbHqcqVPCL51nAnEL_TqGqQnvpgo',
    appId: '1:76973833387:android:20403c5692363debdd0bee',
    messagingSenderId: '76973833387',
    projectId: 'naksimpan-ca5c7',
    storageBucket: 'YOUR_STORAGE_BUCKET', // optional
  );
}
