// archivo de ejemplo
// genera el real con: flutterfire configure
// luego copia/renombra este archivo a firebase_options.dart si lo necesitas

// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('plataforma no configurada, ejecuta flutterfire configure');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'API_KEY_WEB',
    appId: 'APP_ID_WEB',
    messagingSenderId: 'SENDER_ID',
    projectId: 'TU_PROYECTO_FIREBASE',
    authDomain: 'TU_PROYECTO_FIREBASE.firebaseapp.com',
    storageBucket: 'TU_PROYECTO_FIREBASE.appspot.com',
    measurementId: 'MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'API_KEY_ANDROID',
    appId: 'APP_ID_ANDROID',
    messagingSenderId: 'SENDER_ID',
    projectId: 'TU_PROYECTO_FIREBASE',
    storageBucket: 'TU_PROYECTO_FIREBASE.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'API_KEY_IOS',
    appId: 'APP_ID_IOS',
    messagingSenderId: 'SENDER_ID',
    projectId: 'TU_PROYECTO_FIREBASE',
    storageBucket: 'TU_PROYECTO_FIREBASE.appspot.com',
    iosBundleId: 'com.tu.paquete',
  );
}
