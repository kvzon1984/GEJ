// Este archivo será generado automáticamente cuando ejecutes: flutterfire configure
// Por ahora, contiene una configuración placeholder

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
    apiKey: 'AIzaSyANct37SOf2hF8q5pmjwmbw-VDL0qV93P4',
    appId: '1:323372141270:web:b8a30fde9c498d2c5dd777',
    messagingSenderId: '323372141270',
    projectId: 'gejv1-83264',
    authDomain: 'gejv1-83264.firebaseapp.com',
    storageBucket: 'gejv1-83264.firebasestorage.app',
    measurementId: 'G-D0VCKCZJG3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAVqiOm7wgQph1ETIDE8YLszFpqKqolYWU',
    appId: '1:323372141270:android:2eb770e88567b1b25dd777',
    messagingSenderId: '323372141270',
    projectId: 'gejv1-83264',
    storageBucket: 'gejv1-83264.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDvrzJ25sA6FDq8rMJN3PLnTXb4O2AaSG8',
    appId: '1:323372141270:ios:ec04655bc0b4ee7e5dd777',
    messagingSenderId: '323372141270',
    projectId: 'gejv1-83264',
    storageBucket: 'gejv1-83264.firebasestorage.app',
    iosBundleId: 'com.example.gejApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDvrzJ25sA6FDq8rMJN3PLnTXb4O2AaSG8',
    appId: '1:323372141270:ios:ec04655bc0b4ee7e5dd777',
    messagingSenderId: '323372141270',
    projectId: 'gejv1-83264',
    storageBucket: 'gejv1-83264.firebasestorage.app',
    iosBundleId: 'com.example.gejApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyANct37SOf2hF8q5pmjwmbw-VDL0qV93P4',
    appId: '1:323372141270:web:1a5b784c74c77c4d5dd777',
    messagingSenderId: '323372141270',
    projectId: 'gejv1-83264',
    authDomain: 'gejv1-83264.firebaseapp.com',
    storageBucket: 'gejv1-83264.firebasestorage.app',
    measurementId: 'G-GK1C73BZCW',
  );

}