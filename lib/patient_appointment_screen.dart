import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shifa/services/firebase_services.dart';
import 'doctor_chat_screen.dart';

class PatientAppointmentsScreen extends StatelessWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebase = FirebaseServices();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Appointments"),
        backgroundColor: const Color(0xff009f93),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebase.getPatientAppointments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No appointments yet"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return PatientAppointmentCard(
                appointmentId: docs[index].id,
                doctorName: data['doctorName'],
                doctorSpecialty: data['doctorSpecialty'],
                date: (data['date'] as Timestamp).toDate(),
                time: data['time'],
                status: data['status'],
              );
            },
          );
        },
      ),
    );
  }
}

class PatientAppointmentCard extends StatelessWidget {
  final String appointmentId;
  final String doctorName;
  final String doctorSpecialty;
  final DateTime date;
  final String time;
  final String status;

  const PatientAppointmentCard({
    super.key,
    required this.appointmentId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.date,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final firebase = FirebaseServices();

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doctorName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(doctorSpecialty, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),

            Text("Date: ${date.day}/${date.month}/${date.year}"),
            Text("Time: $time"),
            const SizedBox(height: 6),

            _StatusChip(status),
            const SizedBox(height: 12),

            if (status == 'accepted')
              ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text("Chat with Doctor"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff009f93),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DoctorChatScreen(appointmentId: appointmentId),
                    ),
                  );
                },
              ),

            if (status == 'pending')
              const Text(
                "Waiting for doctor approval",
                style: TextStyle(color: Colors.orange),
              ),

            if (status == 'completed')
              const Text(
                "Appointment completed",
                style: TextStyle(color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status) {
      case 'accepted':
        color = Colors.green;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      default:
        color = Colors.orange;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}
