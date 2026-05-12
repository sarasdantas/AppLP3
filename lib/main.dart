import 'package:flutter/material.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';

const firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyDPBlZvUpr6WxfTc-3JXdDvDEoCRiNlcek",
  authDomain: "casa-limpa-5d2ea.firebaseapp.com",
  projectId: "casa-limpa-5d2ea",
  storageBucket: "casa-limpa-5d2ea.firebasestorage.app",
  messagingSenderId: "273028476826",
  appId: "1:273028476826:web:15f93e554f4b91c5731423",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(const App());
}
