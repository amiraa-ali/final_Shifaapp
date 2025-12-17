import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shifa/Services/firebase_services.dart';
import 'welcome.dart';

class PatientGuard extends StatelessWidget {
  final Widget child;

  const PatientGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const WelcomeScreen();
        }

        return FutureBuilder<String?>(
          future: FirebaseServices().getCurrentUserRole(),
          builder: (context, roleSnapshot) {
            if (!roleSnapshot.hasData) {
              return const WelcomeScreen();
            }

            if (roleSnapshot.data != 'patient') {
              return const WelcomeScreen();
            }

            return child;
          },
        );
      },
    );
  }
}
