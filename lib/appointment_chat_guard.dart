import 'package:flutter/material.dart';
import 'package:shifa/Services/firebase_services.dart';
import 'welcome.dart';

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
        if (!snapshot.hasData) {
          return const WelcomeScreen();
        }

        final data = snapshot.data!;
        final uid = firebase.currentUserId;

        final isParticipant =
            data['patientId'] == uid || data['doctorId'] == uid;

        if (!isParticipant || data['status'] != 'accepted') {
          return const WelcomeScreen();
        }

        return child;
      },
    );
  }
}
