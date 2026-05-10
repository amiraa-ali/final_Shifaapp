import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shifa/Authgate.dart';
import 'package:shifa/app_theme.dart';

import 'firebase_options.dart';

const String _supabaseUrl = 'https://ibwqdlfsriynbavasagu.supabase.co';

const String _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
    '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlid3FkbGZzcml5bmJhdmFzYWd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxODYxNzMsImV4cCI6MjA5Mzc2MjE3M30'
    '.nL8h_5yvH0Iq_9QHQfMnAQycC3zEDDA4rqee6oQVjYo';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeServices();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ShifaApp());
}

Future<void> _initializeServices() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,

    authOptions: const FlutterAuthClientOptions(autoRefreshToken: true),
  );
}

class ShifaApp extends StatelessWidget {
  const ShifaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Shifa',

      theme: AppTheme.light,

      themeMode: ThemeMode.light,

      home: const AuthGate(),

      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),

          child: child!,
        );
      },
    );
  }
}
