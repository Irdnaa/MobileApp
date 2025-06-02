// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      // Add other platforms if needed
      default:
        throw UnsupportedError(
            'DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCeBQtDbHqcqVPCL51nAnEL_TqGqQnvpgo',
    appId: '1:76973833387:android:20403c5692363debdd0bee',
    messagingSenderId: '76973833387',
    projectId: 'naksimpan-ca5c7',
    storageBucket: 'naksimpan-ca5c7.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY_HERE', // Replace with your actual iOS apiKey
    appId: 'YOUR_IOS_APP_ID_HERE', // Replace with your actual iOS appId
    messagingSenderId: '76973833387',
    projectId: 'naksimpan-ca5c7',
    storageBucket: 'naksimpan-ca5c7.appspot.com',
    iosBundleId: 'YOUR_IOS_BUNDLE_ID', // Optional but recommended
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDO1waSbhj-Lcu6YPwokid-jZ_y7xGuTCg',
    authDomain: 'naksimpan-ca5c7.firebaseapp.com',
    projectId: 'naksimpan-ca5c7',
    storageBucket: 'naksimpan-ca5c7.firebasestorage.app',
    messagingSenderId: '76973833387',
    appId: '1:76973833387:web:969f059048629217dd0bee',
    measurementId: 'G-HB8DGL24L1',
    iosBundleId: '',
  );
}

// class FirebaseOptions {
//   const FirebaseOptions(
//       {required String apiKey,
//       required String appId,
//       required String messagingSenderId,
//       required String projectId,
//       required String storageBucket,
//       required String iosBundleId,
//       required String authDomain,
//       required String measurementId});
// }
