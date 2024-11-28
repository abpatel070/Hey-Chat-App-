import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hey2/Theme/light_mode.dart';
import 'package:hey2/firebase_options.dart';
import 'package:hey2/pages/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "hey-ae396",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      theme: lightMode,
    );
  }
}
