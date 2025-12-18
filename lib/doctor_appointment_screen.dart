import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shifa/Services/firebase_services.dart';

class DoctorAppointmentScreen extends StatefulWidget {
  const DoctorAppointmentScreen({super.key});

  @override
  State<DoctorAppointmentScreen> createState() =>
      _DoctorAppointmentScreenState();
}

class _DoctorAppointmentScreenState extends State<DoctorAppointmentScreen> {
  final FirebaseServices _firebaseServices = FirebaseServices();
  String? doctorId;

  @override
  void initState() {
    super.initState();
    doctorId = _firebaseServices.getCurrentUserId();
  }

  @override
  Widget build(BuildContext context) {
    if (doctorId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.error_outline, size: 60, color: Colors.red),
              SizedBox(height: 16),
              Text('Error: Not logged in'),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: _buildCustomAppBar(context),
        body: TabBarView(
          children: [
            // Today's Appointments
            _buildAppointmentList(
              _firebaseServices.getTodayAppointments(doctorId!),
              'today',
            ),
            // Upcoming Appointments
            _buildAppointmentList(
              _firebaseServices.getUpcomingAppointments(doctorId!),
              'upcoming',
            ),
            // Completed Appointments
            _buildAppointmentList(
              _firebaseServices.getCompletedAppointments(doctorId!),
              'completed',
            ),
            // Cancelled Appointments
            _buildAppointmentList(
              _firebaseServices.getCancelledAppointments(doctorId!),
              'cancelled',
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(140.0),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff39ab4a), Color(0xff009f93)],
            end: Alignment.topLeft,
            begin: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25.0),
            bottomRight: Radius.circular(25.0),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 19,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Appointments",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          "Manage your appointments",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: "Today"),
                  Tab(text: "Upcoming"),
                  Tab(text: "Completed"),
                  Tab(text: "Cancelled"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentList(Stream<QuerySnapshot> stream, String tabType) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _getEmptyMessage(tabType),
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final appointments = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final doc = appointments[index];
            final data = doc.data() as Map<String, dynamic>;

            return AppointmentCard(
              appointmentId: doc.id,
              patientName: data['patientName'] ?? 'Unknown Patient',
              specialty: data['doctorSpecialty'] ?? 'General',
              time: data['appointmentTime'] ?? 'N/A',
              fees: (data['fees'] ?? 0).toDouble(),
              paymentMethod: data['paymentMethod'] ?? 'Cash',
              status: data['status'] ?? 'upcoming',
              tabType: tabType,
              onUpdate: () {
                setState(() {});
              },
            );
          },
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
  final FirebaseServices _firebaseServices = FirebaseServices();
  bool isUpdating = false;

  Future<void> _markAsCompleted() async {
    setState(() => isUpdating = true);

    try {
      bool success = await _firebaseServices.markAppointmentCompleted(
        widget.appointmentId,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment marked as completed'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onUpdate();
      } else {
        throw Exception('Failed to update status');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isUpdating = false);
      }
    }
  }

  Future<void> _cancelAppointment() async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isUpdating = true);

    try {
      bool success = await _firebaseServices.cancelAppointment(
        widget.appointmentId,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
        widget.onUpdate();
      } else {
        throw Exception('Failed to cancel appointment');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isUpdating = false);
      }
    }
  }

  Future<void> _restoreAppointment() async {
    setState(() => isUpdating = true);

    try {
      bool success = await _firebaseServices.updateAppointmentStatus(
        widget.appointmentId,
        'upcoming',
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment restored'),
            backgroundColor: Colors.blue,
          ),
        );
        widget.onUpdate();
      } else {
        throw Exception('Failed to restore appointment');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine booking color based on payment method
    Color bookingColor;
    String bookingText;

    if (widget.paymentMethod.toLowerCase().contains('cash')) {
      bookingColor = Colors.green;
      bookingText = "Cash";
    } else {
      bookingColor = Colors.blue;
      bookingText = "Online";
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.patientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fees: ${widget.fees.toStringAsFixed(0)} EGP',
                        style: TextStyle(
                          color: Colors.blueGrey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(bookingText, bookingColor),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.specialty,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey, size: 18),
                    const SizedBox(width: 5),
                    Text(
                      widget.time,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (isUpdating)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Row(children: _buildActionButtons()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons() {
    if (widget.tabType == 'cancelled') {
      // Cancelled tab - show restore button
      return [
        InkWell(
          onTap: _restoreAppointment,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.undo, color: Colors.white, size: 16),
                SizedBox(width: 3),
                Text(
                  "Restore",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    } else if (widget.tabType == 'completed') {
      // Completed tab - no actions
      return [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 3),
              Text(
                "Completed",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ];
    } else {
      // Today/Upcoming tabs - show mark done and cancel buttons
      return [
        InkWell(
          onTap: _markAsCompleted,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                SizedBox(width: 3),
                Text(
                  "Complete",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: _cancelAppointment,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.cancel, color: Colors.white, size: 16),
                SizedBox(width: 3),
                Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 3, backgroundColor: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
