import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC50DdKkMyRlaQog1X-L85G-otczTtunSQ',
    appId: '1:587383240209:android:e198c65fc147deca8a63b0',
    messagingSenderId: '587383240209',
    projectId: 'jago-hitung',
    storageBucket: 'jago-hitung.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: '587383240209',
    projectId: 'jago-hitung',
    storageBucket: 'jago-hitung.firebasestorage.app',
    iosBundleId: 'com.example.jagoHitung',
  );
}
