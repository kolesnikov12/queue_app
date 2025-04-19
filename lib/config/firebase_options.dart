import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions не налаштовано для ${defaultTargetPlatform.name}',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'test-api-key',
    appId: '1:123456789012:android:1234567890abcdef',
    messagingSenderId: '123456789012',
    projectId: 'my-test-project',
    storageBucket: 'my-test-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'test-api-key',
    appId: '1:123456789012:ios:1234567890abcdef',
    messagingSenderId: '123456789012',
    projectId: 'my-test-project',
    storageBucket: 'my-test-project.appspot.com',
    iosBundleId: 'com.example.myFirstApp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'test-api-key',
    appId: '1:123456789012:web:1234567890abcdef',
    messagingSenderId: '123456789012',
    projectId: 'my-test-project',
    storageBucket: 'my-test-project.appspot.com',
    authDomain: 'my-test-project.firebaseapp.com',
  );
}