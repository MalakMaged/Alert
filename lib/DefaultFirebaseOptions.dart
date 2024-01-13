import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Provide the correct Firebase configuration for your platform (iOS/Android).
    return FirebaseOptions(
        apiKey: 'AIzaSyDpB_K_NvyDIDPS1X_sejhZPwLL4z1kpS4',
        appId: 'com.example.crimebott',
        messagingSenderId: '1:325631276760:android:68a74f3e3aff466efa49ad',
        projectId: 'crimee-f7f63',
        storageBucket: 'crimee-f7f63.appspot.com',
        databaseURL: 'https://crimee-f7f63-default-rtdb.firebaseio.com/');
  }
}
