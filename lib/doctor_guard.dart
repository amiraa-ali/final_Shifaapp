// doctor_guard_complete.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shifa/Services/firebase_services.dart';

class DoctorGuard extends StatelessWidget {
  final Widget child;

  const DoctorGuard({super.key, required this.child});

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

            // Role check failed or user is not a doctor
            if (!roleSnapshot.hasData || roleSnapshot.data != 'doctor') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // If user is a patient, redirect to patient home
                if (roleSnapshot.data == 'patient') {
                  Navigator.of(context).pushReplacementNamed('/patient-home');
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

            // User is a doctor, show protected content
            return child;
          },
        );
      },
    );
  }
}

// ========================================================
// appointment_chat_guard_complete.dart
// ========================================================

class AppointmentChatGuard extends StatelessWidget {
  final String appointmentId;
  final Widget child;

  const AppointmentChatGuard({
    super.key,
    required this.appointmentId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final firebase = FirebaseServices();

    return FutureBuilder<Map<String, dynamic>?>(
      future: firebase.getAppointmentById(appointmentId),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.teal)),
          );
        }

        // No data or error
        if (!snapshot.hasData || snapshot.data == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/welcome');
          });
          return const Scaffold(
            body: Center(child: Text('Appointment not found')),
          );
        }

        final data = snapshot.data!;
        final uid = firebase.currentUserId;

        // Check if user is a participant
        final isParticipant =
            data['patientId'] == uid || data['doctorId'] == uid;

        // Check if appointment status allows chat
        // Allow chat for upcoming and completed appointments
        final canChat =
            data['status'] == 'upcoming' || data['status'] == 'completed';

        if (!isParticipant || !canChat) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/welcome');
          });
          return const Scaffold(body: Center(child: Text('Access denied')));
        }

        return child;
      },
    );
  }
}
