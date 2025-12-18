import 'package:flutter/material.dart';
// import 'package:nav1/doctor_home_screen.dart';
// import 'package:nav1/homepage.dart';
import 'package:shifa/welcome.dart';
// import 'homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ShifaApp());
}

class ShifaApp extends StatelessWidget {
  const ShifaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}
