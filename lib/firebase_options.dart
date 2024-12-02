// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDBOswSRgxUBH7v6btByTHcEyzSzgEibXM',
    appId: '1:259421280188:web:26fee173e5e5f907f0fdb9',
    messagingSenderId: '259421280188',
    projectId: 'papertrailpit-76d98',
    authDomain: 'papertrailpit-76d98.firebaseapp.com',
    storageBucket: 'papertrailpit-76d98.firebasestorage.app',
    measurementId: 'G-EHWZN53GWT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCXt2T6tEqokoiuadRGyopzJTRY7WItCdo',
    appId: '1:259421280188:android:b94b543c036b1a01f0fdb9',
    messagingSenderId: '259421280188',
    projectId: 'papertrailpit-76d98',
    storageBucket: 'papertrailpit-76d98.firebasestorage.app',
  );
}
