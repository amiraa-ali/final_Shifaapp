import 'package:flutter/material.dart';
import 'package:shifa/Services/firebase_services.dart';
import 'package:shifa/doctor_home_screen.dart';
import 'package:shifa/patient_home_screen.dart';
import 'package:shifa/welcome.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseServices = FirebaseServices();

    final user = firebaseServices.getCurrentUser();

    if (user == null) {
      return WelcomeScreen();
    }
    return FutureBuilder<String?>(
      future: firebaseServices.getCurrentUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Unable to determine user role')),
          );
        }

        final role = snapshot.data;

        if (role == 'doctor') {
          return DoctorHomeScreen();
        } else if (role == 'patient') {
          return PatientHomeScreen();
        }

        return const Scaffold(body: Center(child: Text('Invalid role')));
      },
    );
  }
}
