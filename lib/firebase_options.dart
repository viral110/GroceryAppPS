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
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCHD4EBFAAMpU3xYQ7ur8hDSWzDpq6bhDU',
    appId: '1:389529207938:android:28fb56dd17d235eb0ca09b',
    messagingSenderId: '389529207938',
    projectId: 'grocery-app-ps',
    storageBucket: 'grocery-app-ps.firebasestorage.app',
  );
  // ANDROID (Consumer App)

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCDQfod1nbFXCVF5O1yBERmIDHca69Bm54',
    appId: '1:389529207938:ios:3407814b502b809c0ca09b',
    messagingSenderId: '389529207938',
    projectId: 'grocery-app-ps',
    storageBucket: 'grocery-app-ps.firebasestorage.app',
    iosBundleId: 'com.groceryps.ios',
  );

  // iOS placeholder

  // // Web placeholder
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDNoOyXyDkevSgGka92n-kJwhk9vLL78V4",
    authDomain: "grocery-app-ps.firebaseapp.com",
    projectId: "grocery-app-ps",
    storageBucket: "grocery-app-ps.firebasestorage.app",
    messagingSenderId: "389529207938",
    appId: "1:389529207938:web:3862c722a69cbc450ca09b",
    measurementId: "G-22BKVG7VFN",
  );
}
