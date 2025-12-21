import 'package:flutter/material.dart';
import 'package:shifa/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' ;
import 'firebase_options.dart';

void main() async {
  // firebase initialization 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);



// supabase init.
  await Supabase.initialize(
    url :'https://kbytsawnhvgvpeeakvxa.supabase.co',
    anonKey :'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtieXRzYXduaHZndnBlZWFrdnhhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU4ODYyMjcsImV4cCI6MjA4MTQ2MjIyN30.66fYcZ1DE__HaEOjInKzlt1vo3DjTPEe2oZCINMZKsI',
  );

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
