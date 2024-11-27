import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCcHdVAv72k1yuwVasCyz4CejIwVZjudHM',
    appId: '1:967021757823:android:763c658f24943f710cc64a',
    messagingSenderId: '967021757823',
    projectId: 'ninte-8ab39',
    storageBucket: 'ninte-8ab39.firebasestorage.app',
    androidClientId: '967021757823-mr4v5nnm040oruo9clk908t2rsjlrfsh.apps.googleusercontent.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB20Ec-c76_nQDoBtTN1h60gOOcfStGiJU',
    appId: '1:967021757823:ios:6022bbaf27a806d80cc64a',
    messagingSenderId: '967021757823',
    projectId: 'ninte-8ab39',
    storageBucket: 'ninte-8ab39.appspot.com',
    iosClientId: 'your-ios-client-id',
    iosBundleId: 'com.xdaguy.ninte',
  );
} 