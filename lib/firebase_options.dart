import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      // case TargetPlatform.iOS:
      //   return ios;
    // You can add configurations for other platforms like macOS here
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyDludI03WxHef8iqM6pzVhJVuwss_OpxLA",
      authDomain: "laundry-app-7c71c.firebaseapp.com",
      projectId: "laundry-app-7c71c",
      storageBucket: "laundry-app-7c71c.firebasestorage.app",
      messagingSenderId: "780557528501",
      appId: "1:780557528501:web:ba931f5adab2b22790bdfc",
      measurementId: "G-KP7KXF0TH3"
  );

  static const FirebaseOptions android = FirebaseOptions(
      apiKey: "AIzaSyDludI03WxHef8iqM6pzVhJVuwss_OpxLA",
      authDomain: "laundry-app-7c71c.firebaseapp.com",
      projectId: "laundry-app-7c71c",
      storageBucket: "laundry-app-7c71c.firebasestorage.app",
      messagingSenderId: "780557528501",
      appId: "1:780557528501:web:ba931f5adab2b22790bdfc",
      measurementId: "G-KP7KXF0TH3"

  );

}