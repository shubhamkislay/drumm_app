// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDO_iy90QgwoTWGMvJxIPb-5pi5wiemY0g',
    appId: '1:1041818095145:android:db8a647a135cc3dc711638',
    messagingSenderId: '1041818095145',
    projectId: 'drummapp',
    databaseURL: 'https://drummapp-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'drummapp.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC4Slfg2hUeplMT_3EuEDzeTSreDH-N3rU',
    appId: '1:1041818095145:ios:cd7c7c5cae81a18f711638',
    messagingSenderId: '1041818095145',
    projectId: 'drummapp',
    databaseURL: 'https://drummapp-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'drummapp.appspot.com',
    androidClientId: '1041818095145-hr93hj81hcio5jc2scou9vrtqh71oad6.apps.googleusercontent.com',
    iosClientId: '1041818095145-4tatbm4m5g8f0has19jkv1aboa1g3ils.apps.googleusercontent.com',
    iosBundleId: 'app.drumm',
  );
}
