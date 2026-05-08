import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shifa/Services/firebase_services.dart';

class PatientGuard extends StatelessWidget {
  final Widget child;

  const PatientGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.teal)),
          );
        }

        // Not logged in
        if (!snapshot.hasData || snapshot.data == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/welcome');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.teal)),
          );
        }

        // Check user role
        return FutureBuilder<String?>(
          future: FirebaseServices().getCurrentUserRole(),
          builder: (context, roleSnapshot) {
            // Loading role
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Colors.teal),
                ),
              );
            }

            // Role check failed or user is not a patient
            if (!roleSnapshot.hasData || roleSnapshot.data != 'patient') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // If user is a doctor, redirect to doctor home
                if (roleSnapshot.data == 'doctor') {
                  Navigator.of(context).pushReplacementNamed('/doctor-home');
                } else {
                  // Unknown role, redirect to welcome
                  Navigator.of(context).pushReplacementNamed('/welcome');
                }
              });
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Colors.teal),
                ),
              );
            }

            // User is a patient, show protected content
            return child;
          },
        );
      },
    );
  }
}
