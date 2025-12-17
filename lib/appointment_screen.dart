import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shifa/Services/firebase_services.dart';
import 'doctor_chat_screen.dart';
import 'doctor_guard.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DoctorGuard(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Appointments"),
            backgroundColor: const Color(0xff009f93),
            bottom: const TabBar(
              tabs: [
                Tab(text: "Pending"),
                Tab(text: "Accepted"),
                Tab(text: "Completed"),
              ],
            ),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseServices().getDoctorAppointments(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              return TabBarView(
                children: [
                  _DoctorList(docs, 'pending'),
                  _DoctorList(docs, 'accepted'),
                  _DoctorList(docs, 'completed'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DoctorList extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  final String status;

  const _DoctorList(this.docs, this.status);

  @override
  Widget build(BuildContext context) {
    final filtered = docs.where((d) {
      return (d.data() as Map<String, dynamic>)['status'] == status;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("No appointments"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final data = filtered[i].data() as Map<String, dynamic>;
        return DoctorAppointmentCard(
          appointmentId: filtered[i].id,
          patientId: data['patientId'],
          date: (data['date'] as Timestamp).toDate(),
          time: data['time'],
          status: data['status'],
        );
      },
    );
  }
}

class DoctorAppointmentCard extends StatelessWidget {
  final String appointmentId;
  final String patientId;
  final DateTime date;
  final String time;
  final String status;

  const DoctorAppointmentCard({
    super.key,
    required this.appointmentId,
    required this.patientId,
    required this.date,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final firebase = FirebaseServices();

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, dynamic>?>(
              future: firebase.getPatientById(patientId),
              builder: (_, snap) {
                return Text(
                  snap.data?['fullName'] ?? 'Patient',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                );
              },
            ),
            Text("Date: ${date.day}/${date.month}/${date.year}"),
            Text("Time: $time"),
            Text("Status: $status"),
            const SizedBox(height: 10),

            if (status == 'pending')
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => firebase.updateAppointmentStatus(
                      appointmentId: appointmentId,
                      status: 'accepted',
                    ),
                    child: const Text("Accept"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => firebase.updateAppointmentStatus(
                      appointmentId: appointmentId,
                      status: 'rejected',
                    ),
                    child: const Text("Reject"),
                  ),
                ],
              ),

            if (status == 'accepted')
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.chat),
                    label: const Text("Chat"),
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
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => firebase.updateAppointmentStatus(
                      appointmentId: appointmentId,
                      status: 'completed',
                    ),
                    child: const Text("Complete"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
