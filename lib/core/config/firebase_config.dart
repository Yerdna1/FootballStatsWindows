import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your-web-api-key',
    appId: '1:your-project-number:web:your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'football-stats-app',
    authDomain: 'football-stats-app.firebaseapp.com',
    storageBucket: 'football-stats-app.appspot.com',
    measurementId: 'G-your-measurement-id',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key',
    appId: '1:your-project-number:android:your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'football-stats-app',
    storageBucket: 'football-stats-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: '1:your-project-number:ios:your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'football-stats-app',
    storageBucket: 'football-stats-app.appspot.com',
    iosBundleId: 'com.footballstats.footballStats',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-macos-api-key',
    appId: '1:your-project-number:ios:your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'football-stats-app',
    storageBucket: 'football-stats-app.appspot.com',
    iosBundleId: 'com.footballstats.footballStats',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'your-windows-api-key',
    appId: '1:your-project-number:web:your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'football-stats-app',
    authDomain: 'football-stats-app.firebaseapp.com',
    storageBucket: 'football-stats-app.appspot.com',
    measurementId: 'G-your-measurement-id',
  );
}