// lib/doctor_home_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shifa/Services/firebase_services.dart';
import 'package:shifa/doctor_appointment_screen.dart';
import 'doctor_chat_screen.dart';
import 'doctor_profile.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  _DoctorHomeScreenState createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final FirebaseServices _firebaseServices = FirebaseServices();
  int index = 0;

  String doctorName = 'Dr. Loading...';
  String specialty = 'Loading...';
  String? doctorId;

  int todayCount = 0;
  int upcomingCount = 0;
  int totalPatients = 0;
  double monthlyRevenue = 0.0;

  bool isLoadingProfile = true;
  bool isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    doctorId = _firebaseServices.getCurrentUserId();

    if (doctorId != null) {
      // Load doctor profile
      await _loadDoctorProfile();
      // Load statistics
      await _loadStatistics();
    }
  }

  Future<void> _loadDoctorProfile() async {
    setState(() => isLoadingProfile = true);

    Map<String, dynamic>? profile = await _firebaseServices.getDoctorProfile(
      doctorId!,
    );

    if (profile != null) {
      setState(() {
        doctorName = profile['name'] ?? 'Dr. Unknown';
        specialty = profile['specialization'] ?? 'General Practitioner';
        isLoadingProfile = false;
      });
    } else {
      setState(() => isLoadingProfile = false);
    }
  }

  Future<void> _loadStatistics() async {
    setState(() => isLoadingStats = true);

    int today = await _firebaseServices.getTodayAppointmentCount(doctorId!);
    int upcoming = await _firebaseServices.getUpcomingAppointmentCount(
      doctorId!,
    );
    int patients = await _firebaseServices.getTotalPatientsCount(doctorId!);
    double revenue = await _firebaseServices.getMonthlyRevenue(doctorId!);

    setState(() {
      todayCount = today;
      upcomingCount = upcoming;
      totalPatients = patients;
      monthlyRevenue = revenue;
      isLoadingStats = false;
    });
  }

  List<Widget> get pages => [
    const SizedBox(),
    const DoctorChatScreen(),
    DoctorAppointmentScreen(),
    const DoctorProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    if (doctorId == null) {
      return const Scaffold(body: Center(child: Text('Error: Not logged in')));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          setState(() {
            index = i;
          });
        },
        height: 60,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.teal),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat, color: Colors.teal),
            label: 'Chat',
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
      body: index == 0
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  _buildStatsGrid(),
                  _buildQuickActions(),
                  _buildTodayTasks(),
                  const SizedBox(height: 30),
                ],
              ),
            )
          : pages[index],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1ABC9C), Color(0xFF2ECC71)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back,',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    Text(
                      isLoadingProfile ? 'Loading...' : doctorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      isLoadingProfile ? 'Loading...' : specialty,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Text(
                    doctorName
                        .split(' ')
                        .map((e) => e.isNotEmpty ? e[0] : '')
                        .take(2)
                        .join(),
                    style: const TextStyle(
                      color: Color(0xFF1ABC9C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      padding: const EdgeInsets.all(15),
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      children: <Widget>[
        _buildStatCard(
          icon: Icons.calendar_today,
          value: isLoadingStats ? '...' : todayCount.toString(),
          label: 'Today\'s Appointments',
          color: const Color(0xFF1ABC9C),
        ),
        _buildStatCard(
          icon: Icons.watch_later_outlined,
          value: isLoadingStats ? '...' : upcomingCount.toString(),
          label: 'Upcoming Bookings',
          color: Colors.blueAccent,
        ),
        _buildStatCard(
          icon: Icons.people_outline,
          value: isLoadingStats ? '...' : totalPatients.toString(),
          label: 'Total Patients',
          color: Colors.orange,
        ),
        _buildStatCard(
          icon: Icons.attach_money,
          value: isLoadingStats
              ? '...'
              : 'EGP ${monthlyRevenue.toStringAsFixed(0)}',
          label: 'This Month Revenue',
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildActionButton(
                Icons.calendar_month,
                'View Schedule',
                const Color(0xFFD4EAE5),
                () {
                  setState(() => index = 2);
                },
              ),
              const SizedBox(width: 15),
              _buildActionButton(
                Icons.refresh,
                'Refresh',
                const Color(0xFFE5F5D4),
                () {
                  _loadDoctorData();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color bgColor,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF1ABC9C), size: 30),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayTasks() {
    if (doctorId == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Schedule',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => index = 2);
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF1ABC9C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: _firebaseServices.getTodayAppointments(doctorId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No appointments today',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  return _buildAppointmentItem(
                    patientName: data['patientName'] ?? 'Unknown',
                    time: data['appointmentTime'] ?? 'N/A',
                    purpose: data['doctorSpecialty'] ?? 'General',
                    type: data['paymentMethod'] ?? 'Online',
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem({
    required String patientName,
    required String time,
    required String purpose,
    required String type,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patientName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                time,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: type.toLowerCase().contains('cash')
                      ? Colors.green.shade50
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: type.toLowerCase().contains('cash')
                        ? Colors.green.shade700
                        : Colors.blue.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                purpose,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
