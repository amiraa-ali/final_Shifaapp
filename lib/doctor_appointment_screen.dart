import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:shifa/Services/appointment_service.dart';
import 'package:shifa/doctor_home_screen.dart';

class DoctorAppointmentScreen extends StatefulWidget {
  final int initialTabIndex;

  const DoctorAppointmentScreen({super.key, this.initialTabIndex = 0});

  @override
  State<DoctorAppointmentScreen> createState() =>
      _DoctorAppointmentScreenState();
}

class _DoctorAppointmentScreenState extends State<DoctorAppointmentScreen> {
  final AppointmentService _appointmentService = AppointmentService();

  late Future<List<dynamic>> todayAppointments;

  late Future<List<dynamic>> upcomingAppointments;

  late Future<List<dynamic>> completedAppointments;

  late Future<List<dynamic>> cancelledAppointments;

  @override
  void initState() {
    super.initState();

    _loadAppointments();
  }

  void _loadAppointments() {
    todayAppointments = _appointmentService.getTodayAppointments();

    upcomingAppointments = _appointmentService.getUpcomingAppointments();

    completedAppointments = _appointmentService.getCompletedAppointments();

    cancelledAppointments = _appointmentService.getCancelledAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: widget.initialTabIndex,

      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),

        appBar: _buildCustomAppBar(context),

        body: TabBarView(
          children: [
            _buildAppointmentList(todayAppointments, 'today'),

            _buildAppointmentList(upcomingAppointments, 'upcoming'),

            _buildAppointmentList(completedAppointments, 'completed'),

            _buildAppointmentList(cancelledAppointments, 'cancelled'),
          ],
        ),
      ),
    );
  }

PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(165),

    child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff39ab4a), Color(0xff009f93)],
          end: Alignment.topLeft,
          begin: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),

      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),

              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),

                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DoctorHomeScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 8),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: const [
                      Text(
                        'Appointments',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),

                      SizedBox(height: 2),

                      Text(
                        'Manage your appointments',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),

              child: const TabBar(
                dividerColor: Colors.transparent,

                indicatorSize: TabBarIndicatorSize.tab,

                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),

                indicatorPadding: EdgeInsets.all(4),

                labelColor: Color(0xff009f93),

                unselectedLabelColor: Colors.white,

                labelStyle: TextStyle(fontWeight: FontWeight.bold),

                tabs: [
                  Tab(text: 'Today'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Cancelled'),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildAppointmentList(Future<List<dynamic>> future, String tabType) {
    return FutureBuilder<List<dynamic>>(
      future: future,

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        }

        if (snapshot.hasError) {
          return _EmptyState(
            icon: Icons.error_outline,
            title: 'Something went wrong',
            subtitle: snapshot.error.toString(),
            iconColor: Colors.red,
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _EmptyState(
            icon: Icons.calendar_today_outlined,

            title: _getEmptyMessage(tabType),

            subtitle: 'Appointments will appear here',
          );
        }

        final appointments = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _loadAppointments();
            });
          },

          child: ListView.builder(
            physics: const BouncingScrollPhysics(),

            padding: const EdgeInsets.all(16),

            itemCount: appointments.length,

            itemBuilder: (context, index) {
              final data = appointments[index];

              return AppointmentCard(
                appointmentId: data['_id'] ?? '',

                patientName: data['patientName'] ?? 'Unknown',

                specialty: data['specialization'] ?? 'General',

                appointmentDate: DateTime.tryParse(
                  data['appointmentDate'] ?? '',
                ),

                time: data['appointmentTime'] ?? 'N/A',

                fees: (data['fees'] ?? 0).toDouble(),

                paymentMethod: data['paymentMethod'] ?? 'Cash',

                status: data['status'] ?? 'upcoming',

                tabType: tabType,

                onUpdate: () {
                  setState(() {
                    _loadAppointments();
                  });
                },
              );
            },
          ),
        );
      },
    );
  }

  String _getEmptyMessage(String tabType) {
    switch (tabType) {
      case 'today':
        return 'No appointments today';

      case 'upcoming':
        return 'No upcoming appointments';

      case 'completed':
        return 'No completed appointments';

      case 'cancelled':
        return 'No cancelled appointments';

      default:
        return 'No appointments';
    }
  }
}

class AppointmentCard extends StatefulWidget {
  final String appointmentId;

  final String patientName;

  final String specialty;

  final DateTime? appointmentDate;

  final String time;

  final double fees;

  final String paymentMethod;

  final String status;

  final String tabType;

  final VoidCallback onUpdate;

  const AppointmentCard({
    super.key,
    required this.appointmentId,
    required this.patientName,
    required this.specialty,
    this.appointmentDate,
    required this.time,
    required this.fees,
    required this.paymentMethod,
    required this.status,
    required this.tabType,
    required this.onUpdate,
  });

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  final AppointmentService _appointmentService = AppointmentService();

  bool isUpdating = false;

  String _formatDate() {
    if (widget.appointmentDate == null) {
      return 'No Date';
    }

    return DateFormat('dd/MM/yyyy').format(widget.appointmentDate!);
  }

  Future<void> _markAsCompleted() async {
    setState(() {
      isUpdating = true;
    });

    try {
      await _appointmentService.completeAppointment(widget.appointmentId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment completed'),

          backgroundColor: Colors.green,
        ),
      );

      widget.onUpdate();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  Future<void> _cancelAppointment() async {
    setState(() {
      isUpdating = true;
    });

    try {
      await _appointmentService.cancelAppointment(widget.appointmentId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment cancelled'),

          backgroundColor: Colors.red,
        ),
      );

      widget.onUpdate();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,

      margin: const EdgeInsets.only(bottom: 14),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              widget.patientName,

              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(widget.specialty),

            const SizedBox(height: 12),

            Text(_formatDate()),

            const SizedBox(height: 6),

            Text(widget.time),

            const SizedBox(height: 10),

            Text("${widget.fees} EGP"),

            const SizedBox(height: 16),

            if (isUpdating)
              const CircularProgressIndicator()
            else
              Row(
                children: [
                  if (widget.tabType != 'completed' &&
                      widget.tabType != 'cancelled')
                    ElevatedButton(
                      onPressed: _markAsCompleted,

                      child: const Text("Complete"),
                    ),

                  const SizedBox(width: 10),

                  if (widget.tabType != 'completed' &&
                      widget.tabType != 'cancelled')
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),

                      onPressed: _cancelAppointment,

                      child: const Text("Cancel"),
                    ),
                ],
              ),
          ],
        ),
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
    final color = iconColor ?? Colors.teal;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(icon, size: 60, color: color),

          const SizedBox(height: 16),

          Text(
            title,

            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
