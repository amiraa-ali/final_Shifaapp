import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shifa/AuthGate.dart';
import 'package:shifa/app_theme.dart';

Future<void> testConnection() async {
  try {
    final response = await Dio().get("http://192.168.1.16:5000/health");
    print("SUCCESS:");
    print(response.data);
  } catch (e) {
    print("FAILED:");
    print(e);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Supabase initialization
  await Supabase.initialize(
    url: 'https://ibwqdlfsriynbavasagu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlid3FkbGZzcml5bmJhdmFzYWd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxODYxNzMsImV4cCI6MjA5Mzc2MjE3M30.nL8h_5yvH0Iq_9QHQfMnAQycC3zEDDA4rqee6oQVjYo',
  );

  // 🔥 TEST BACKEND CONNECTION
  await testConnection();

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
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}