import 'package:flutter/material.dart';
import 'package:shifa/auth/doctor_guard.dart';
import 'package:shifa/auth/welcome.dart';
import 'appointment_screen.dart';
import 'doctor_profile.dart';
import 'package:shifa/services/firebase_services.dart';

class DoctorHomeScreen extends StatefulWidget {
  final String doctorName;
  final String specialty;

  const DoctorHomeScreen({
    super.key,
    this.doctorName = 'Dr. Sarah Johnson',
    this.specialty = 'Cardiologist',
  });

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return DoctorGuard(
      child: Scaffold(
        backgroundColor: Colors.grey[50],

        // ================= APP BAR =================
        appBar: AppBar(
          backgroundColor: const Color(0xff009f93),
          title: const Text("Doctor Dashboard"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseServices().logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (_) => false,
                );
              },
            ),
          ],
        ),

        // ================= BOTTOM NAV =================
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) {
            setState(() => index = i);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: Colors.teal),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today, color: Colors.teal),
              label: 'Appointments',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person, color: Colors.teal),
              label: 'Profile',
            ),
          ],
        ),

        // ================= BODY =================
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (index) {
      case 0:
        return _buildHome();
      case 1:
        return const AppointmentsScreen();
      case 2:
        return DoctorProfile();
      default:
        return _buildHome();
    }
  }

  // ================= HOME =================

  Widget _buildHome() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildStatsGrid(),
          _buildQuickActions(),
          _buildTodaySection(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1ABC9C), Color(0xFF2ECC71)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Welcome back,', style: TextStyle(color: Colors.white70)),
          Text(
            widget.doctorName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(widget.specialty, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  // ================= ANALYTICS =================

  Widget _buildStatsGrid() {
    final firebase = FirebaseServices();

    return Padding(
      padding: const EdgeInsets.all(15),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        children: [
          _StatFutureCard(
            title: "Today's",
            icon: Icons.calendar_today,
            color: Colors.teal,
            future: firebase.countTodayAppointments(),
          ),
          _StatFutureCard(
            title: "Pending",
            icon: Icons.hourglass_empty,
            color: Colors.orange,
            future: firebase.countDoctorAppointmentsByStatus('pending'),
          ),
          _StatFutureCard(
            title: "Accepted",
            icon: Icons.check_circle_outline,
            color: Colors.green,
            future: firebase.countDoctorAppointmentsByStatus('accepted'),
          ),
          _StatFutureCard(
            title: "Completed",
            icon: Icons.done_all,
            color: Colors.blue,
            future: firebase.countDoctorAppointmentsByStatus('completed'),
          ),
        ],
      ),
    );
  }

  // ================= QUICK ACTIONS =================

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _actionButton(
            Icons.calendar_month,
            'Appointments',
            () => setState(() => index = 1),
          ),
          const SizedBox(width: 15),
          _actionButton(
            Icons.person,
            'Profile',
            () => setState(() => index = 2),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF1ABC9C), size: 30),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Today's Appointments",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () => setState(() => index = 1),
            child: const Text(
              'View All',
              style: TextStyle(color: Color(0xFF1ABC9C)),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= STAT CARD =================

class _StatFutureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Future<int> future;

  const _StatFutureCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.future,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: future,
      builder: (_, snapshot) {
        final value = snapshot.data ?? 0;

        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const Spacer(),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }
}
