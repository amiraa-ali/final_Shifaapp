import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shifa/auth/doctor_guard.dart';
import 'package:shifa/Services/firebase_services.dart';

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
              indicatorColor: Colors.white,
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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text("Something went wrong"));
              }

              final docs = snapshot.data!.docs;

              return TabBarView(
                children: [
                  _AppointmentsList(docs: docs, statusFilter: 'pending'),
                  _AppointmentsList(docs: docs, statusFilter: 'accepted'),
                  _AppointmentsList(docs: docs, statusFilter: 'completed'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ================= LIST PER TAB =================
class _AppointmentsList extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  final String statusFilter;

  const _AppointmentsList({required this.docs, required this.statusFilter});

  @override
  Widget build(BuildContext context) {
    final filtered = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['status'] == statusFilter;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text("No appointments", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final data = filtered[index].data() as Map<String, dynamic>;

        return AppointmentCard(
          appointmentId: filtered[index].id,
          patientId: data['patientId'],
          time: data['time'],
          date: (data['date'] as Timestamp).toDate(),
          status: data['status'],
        );
      },
    );
  }
}

// ================= CARD =================
class AppointmentCard extends StatelessWidget {
  final String appointmentId;
  final String patientId;
  final String time;
  final DateTime date;
  final String status;

  const AppointmentCard({
    super.key,
    required this.appointmentId,
    required this.patientId,
    required this.time,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final firebase = FirebaseServices();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Patient name
            FutureBuilder<Map<String, dynamic>?>(
              future: firebase.getPatientById(patientId),
              builder: (context, snapshot) {
                final patient = snapshot.data;
                final name = patient?['fullName'] ?? 'Patient';

                return Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                );
              },
            ),

            const SizedBox(height: 6),
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
              ElevatedButton(
                onPressed: () => firebase.updateAppointmentStatus(
                  appointmentId: appointmentId,
                  status: 'completed',
                ),
                child: const Text("Mark Completed"),
              ),
          ],
        ),
      ),
    );
  }
}
