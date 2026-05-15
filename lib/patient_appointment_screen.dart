import 'package:flutter/material.dart';

import 'package:shifa/Services/appointment_service.dart';
import 'package:shifa/patient_appointment_card.dart';
import 'package:shifa/patient_appointment_details_screen.dart';
import 'package:shifa/patient_home_screen.dart';
import 'package:shifa/app_theme.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final AppointmentService _appointmentService = AppointmentService();

  List<dynamic> upcomingAppointments = [];

  List<dynamic> pastAppointments = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _loadAppointments();
  }

  // =========================
  // LOAD APPOINTMENTS
  // =========================
  Future<void> _loadAppointments() async {
    try {
      setState(() {
        isLoading = true;
      });

      final upcoming = await _appointmentService.getPatientAppointments(
        filter: "upcoming",
      );

      final past = await _appointmentService.getPatientAppointments(
        filter: "past",
      );

      if (!mounted) return;

      setState(() {
        upcomingAppointments = upcoming;

        pastAppointments = past;

        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        isLoading = false;
      });

      _showSnackBar("Failed to load appointments", isError: true);
    }
  }

  // =========================
  // CANCEL APPOINTMENT
  // =========================
  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      await _appointmentService.cancelAppointment(appointmentId);

      _showSnackBar("Appointment cancelled");

      _loadAppointments();
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    }
  }

  // =========================
  // SNACKBAR
  // =========================
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,

        backgroundColor: isError ? Colors.red : AppColors.primary,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,

        centerTitle: true,

        backgroundColor: AppColors.primary,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),

          onPressed: () {
            Navigator.pushReplacement(
              context,

              MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
            );
          },
        ),

        title: const Text(
          'My Appointments',

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff39ab4a), Color(0xff009f93)],

              begin: Alignment.bottomRight,

              end: Alignment.topLeft,
            ),
          ),
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(65),

          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),

              borderRadius: BorderRadius.circular(18),
            ),

            child: TabBar(
              controller: _tabController,

              dividerColor: Colors.transparent,

              indicator: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(14),
              ),

              indicatorPadding: const EdgeInsets.all(4),

              labelColor: AppColors.primary,

              unselectedLabelColor: Colors.white,

              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,

                fontSize: 14,
              ),

              tabs: const [
                Tab(text: 'Upcoming'),

                Tab(text: 'Past'),
              ],
            ),
          ),
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : TabBarView(
              controller: _tabController,

              children: [
                _buildAppointmentsList(
                  appointments: upcomingAppointments,

                  emptyMessage: 'No upcoming appointments',

                  emptySubtitle: 'Book your first appointment now',

                  emptyIcon: Icons.event_available_rounded,

                  showCancel: true,
                ),

                _buildAppointmentsList(
                  appointments: pastAppointments,

                  emptyMessage: 'No past appointments',

                  emptySubtitle: 'Your appointment history will appear here',

                  emptyIcon: Icons.history_rounded,
                ),
              ],
            ),
    );
  }

  // =========================
  // APPOINTMENTS LIST
  // =========================
  Widget _buildAppointmentsList({
    required List<dynamic> appointments,

    required String emptyMessage,

    required String emptySubtitle,

    required IconData emptyIcon,

    bool showCancel = false,
  }) {
    if (appointments.isEmpty) {
      return _EmptyState(
        icon: emptyIcon,

        title: emptyMessage,

        subtitle: emptySubtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,

      child: ListView.separated(
        physics: const BouncingScrollPhysics(),

        padding: const EdgeInsets.all(16),

        itemCount: appointments.length,

        separatorBuilder: (_, __) => const SizedBox(height: 12),

        itemBuilder: (context, index) {
          final appointment = appointments[index];

          return AppointmentCard(
            appointmentId: appointment["_id"],

            doctorName: appointment["doctor"]?["name"] ?? "Doctor",

            doctorSpecialty:
                appointment["doctor"]?["specialization"] ?? "Specialist",

            appointmentDate: DateTime.parse(appointment["appointmentDate"]),

            appointmentTime: appointment["appointmentTime"] ?? '',

            status: appointment["status"] ?? 'pending',

            fees: (appointment["doctor"]?["fees"] ?? 0).toDouble(),

            clinicLocation: appointment["doctor"]?["clinicLocation"] ?? '',

            paymentMethod: appointment["paymentMethod"] ?? '',

            onTap: () {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) => AppointmentDetailsScreen(
                    appointmentId: appointment["_id"],

                    appointmentData: appointment,
                  ),
                ),
              );
            },

            onCancel: showCancel
                ? () => _cancelAppointment(appointment["_id"])
                : null,
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;

  final String title;

  final String subtitle;

  final Color? iconColor;

  const _EmptyState({
    required this.icon,

    required this.title,

    required this.subtitle,

    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: color.withOpacity(0.08),

                shape: BoxShape.circle,
              ),

              child: Icon(icon, size: 60, color: color),
            ),

            const SizedBox(height: 22),

            Text(title, textAlign: TextAlign.center, style: AppText.h2),

            const SizedBox(height: 10),

            Text(subtitle, textAlign: TextAlign.center, style: AppText.body),
          ],
        ),
      ),
    );
  }
}
