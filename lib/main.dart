import 'package:flutter/material.dart';
import 'package:shifa/Authgate.dart';
import 'package:shifa/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://ibwqdlfsriynbavasagu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlid3FkbGZzcml5bmJhdmFzYWd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxODYxNzMsImV4cCI6MjA5Mzc2MjE3M30.nL8h_5yvH0Iq_9QHQfMnAQycC3zEDDA4rqee6oQVjYo',
  );

  runApp(const ShifaApp());
}

class ShifaApp extends StatelessWidget {
  const ShifaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthGate(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
    );
  }
}