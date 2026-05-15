import 'package:flutter/material.dart';

import 'package:shifa/doctor_appointment_screen.dart';
import 'package:shifa/doctor_chat_screen.dart';
import 'package:shifa/doctor_profile.dart';
import 'package:shifa/app_theme.dart';

import 'package:shifa/Services/auth_service.dart';
import 'package:shifa/Services/appointment_service.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final AuthService _authService = AuthService();

  final AppointmentService _appointmentService = AppointmentService();

  int index = 0;

  String doctorName = 'Dr. Loading...';

  String specialty = 'Loading...';

  int todayCount = 0;

  int upcomingCount = 0;

  int totalPatients = 0;

  double monthlyRevenue = 0.0;

  bool isLoading = true;

  List<dynamic> todayAppointments = [];

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  // =========================
  // LOAD DATA
  // =========================
  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      // PROFILE
      final profile = await _authService.getDoctorProfile();

      // APPOINTMENTS
      final today = await _appointmentService.getTodayAppointments();

      final upcoming = await _appointmentService.getUpcomingAppointments();

      final completed = await _appointmentService.getCompletedAppointments();

      if (!mounted) return;

      setState(() {
        doctorName = profile['name'] ?? 'Doctor';

        specialty = profile['specialization'] ?? 'General';

        todayAppointments = today;

        todayCount = today.length;

        upcomingCount = upcoming.length;

        totalPatients = completed.length;

        monthlyRevenue = completed.fold(
          0.0,
          (sum, item) => sum + ((item['fees'] ?? 0).toDouble()),
        );

        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  List<Widget> get pages => [
    _buildDashboard(),

    const DoctorChatScreen(),

    const DoctorAppointmentScreen(),

    const DoctorProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),

        child: pages[index],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: index,

        height: 72,

        indicatorColor: AppColors.primary.withOpacity(0.15),

        backgroundColor: Colors.white,

        onDestinationSelected: (i) {
          setState(() {
            index = i;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),

            selectedIcon: Icon(Icons.home, color: AppColors.primary),

            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.chat_outlined),

            selectedIcon: Icon(Icons.chat, color: AppColors.primary),

            label: 'Chat',
          ),

          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),

            selectedIcon: Icon(Icons.calendar_today, color: AppColors.primary),

            label: 'Appointments',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),

            selectedIcon: Icon(Icons.person, color: AppColors.primary),

            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // =========================
  // DASHBOARD
  // =========================
  Widget _buildDashboard() {
    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,

        onRefresh: _loadData,

        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    _buildHeader(),

                    const SizedBox(height: 22),

                    _buildStatsGrid(),

                    const SizedBox(height: 12),

                    _buildQuickActions(),

                    const SizedBox(height: 22),

                    _buildTodayTasks(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  // =========================
  // HEADER
  // =========================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),

      decoration: const BoxDecoration(
        gradient: AppColors.mainGradient,

        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),

          bottomRight: Radius.circular(30),
        ),
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Welcome Back 👋',

                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),

                const SizedBox(height: 6),

                Text(
                  doctorName,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.white,

                    fontWeight: FontWeight.bold,

                    fontSize: 26,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  specialty,

                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          Hero(
            tag: 'doctor-profile',

            child: Container(
              width: 60,
              height: 60,

              decoration: BoxDecoration(
                color: Colors.white,

                shape: BoxShape.circle,
              ),

              child: Center(
                child: Text(
                  doctorName
                      .split(' ')
                      .map((e) => e.isNotEmpty ? e[0] : '')
                      .take(2)
                      .join(),

                  style: const TextStyle(
                    color: AppColors.primary,

                    fontWeight: FontWeight.bold,

                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // STATS GRID
  // =========================
  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      crossAxisCount: 2,

      padding: const EdgeInsets.symmetric(horizontal: 20),

      crossAxisSpacing: 14,

      mainAxisSpacing: 14,

      childAspectRatio: 1.1,

      children: [
        _buildStatCard(
          icon: Icons.calendar_today,

          value: todayCount.toString(),

          label: 'Today Appointments',

          color: Colors.teal,
        ),

        _buildStatCard(
          icon: Icons.watch_later_outlined,

          value: upcomingCount.toString(),

          label: 'Upcoming',

          color: Colors.blue,
        ),

        GestureDetector(
          onTap: () {
            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) =>
                    const DoctorAppointmentScreen(initialTabIndex: 2),
              ),
            );
          },

          child: _buildStatCard(
            icon: Icons.people_outline,

            value: totalPatients.toString(),

            label: 'Total Patients',

            color: Colors.orange,
          ),
        ),

        _buildStatCard(
          icon: Icons.attach_money,

          value: 'EGP ${monthlyRevenue.toStringAsFixed(0)}',

          label: 'Revenue',

          color: Colors.purple,
        ),
      ],
    );
  }

  // =========================
  // STAT CARD
  // =========================
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),

            blurRadius: 12,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: color.withOpacity(0.12),

              borderRadius: BorderRadius.circular(16),
            ),

            child: Icon(icon, color: color, size: 26),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                value,

                style: const TextStyle(
                  fontWeight: FontWeight.bold,

                  fontSize: 22,

                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                label,

                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // QUICK ACTIONS
  // =========================
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Quick Actions',

            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.calendar_month,

                  label: 'View Schedule',

                  color: AppColors.primary,

                  onTap: () {
                    setState(() {
                      index = 2;
                    });
                  },
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _buildActionButton(
                  icon: Icons.refresh,

                  label: 'Refresh',

                  color: Colors.blue,

                  onTap: _loadData,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // ACTION BUTTON
  // =========================
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),

      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),

        decoration: BoxDecoration(
          color: color.withOpacity(0.1),

          borderRadius: BorderRadius.circular(20),
        ),

        child: Column(
          children: [
            Icon(icon, color: color, size: 30),

            const SizedBox(height: 10),

            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // =========================
  // TODAY TASKS
  // =========================
  Widget _buildTodayTasks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                'Today Schedule',

                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),

              TextButton(
                onPressed: () {
                  setState(() {
                    index = 2;
                  });
                },

                child: const Text(
                  'View All',

                  style: TextStyle(
                    color: AppColors.primary,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (todayAppointments.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(20),
              ),

              child: const Center(
                child: Text(
                  'No appointments today',

                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Column(
              children: todayAppointments.map((data) {
                return _buildAppointmentItem(
                  patientName: data['patientName'] ?? 'Unknown',

                  time: data['appointmentTime'] ?? 'N/A',

                  purpose: data['specialization'] ?? 'General',

                  type: data['paymentMethod'] ?? 'Cash',
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // =========================
  // APPOINTMENT ITEM
  // =========================
  Widget _buildAppointmentItem({
    required String patientName,
    required String time,
    required String purpose,
    required String type,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),

            blurRadius: 10,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,

            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),

              shape: BoxShape.circle,
            ),

            child: const Icon(Icons.person, color: AppColors.primary),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  patientName,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,

                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(time, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,

            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),

                decoration: BoxDecoration(
                  color: type.toLowerCase().contains('cash')
                      ? Colors.green.shade50
                      : Colors.blue.shade50,

                  borderRadius: BorderRadius.circular(10),
                ),

                child: Text(
                  type,

                  style: TextStyle(
                    fontWeight: FontWeight.bold,

                    fontSize: 12,

                    color: type.toLowerCase().contains('cash')
                        ? Colors.green
                        : Colors.blue,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                purpose,

                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
