import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:shifa/app_theme.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final String appointmentId;

  final Map<String, dynamic> appointmentData;

  const AppointmentDetailsScreen({
    super.key,

    required this.appointmentId,

    required this.appointmentData,
  });

  // =========================
  // STATUS COLOR
  // =========================
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;

      case 'confirmed':
        return AppColors.upcoming;

      case 'completed':
        return AppColors.completed;

      case 'cancelled':
        return AppColors.cancelled;

      default:
        return Colors.grey;
    }
  }

  // =========================
  // STATUS ICON
  // =========================
  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending_actions_rounded;

      case 'confirmed':
        return Icons.event_available_rounded;

      case 'completed':
        return Icons.check_circle_rounded;

      case 'cancelled':
        return Icons.cancel_rounded;

      default:
        return Icons.info_outline_rounded;
    }
  }

  // =========================
  // FORMAT DATE
  // =========================
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // =========================
  // FORMAT TIME
  // =========================
  String _formatTime(String time) {
    try {
      DateTime parsed;

      try {
        parsed = DateFormat('HH:mm').parse(time);
      } catch (_) {
        parsed = DateFormat('h:mm a').parse(time);
      }

      return DateFormat('hh:mm a').format(parsed);
    } catch (_) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    // =========================
    // DOCTOR
    // =========================
    final doctor = appointmentData['doctor'] ?? {};

    final doctorName = doctor['name'] ?? 'Doctor';

    final doctorSpecialty = doctor['specialization'] ?? 'Specialist';

    final fees = (doctor['fees'] ?? 0).toDouble();

    final clinicLocation = doctor['clinicLocation'] ?? 'Clinic';

    // =========================
    // APPOINTMENT
    // =========================
    final appointmentDate = DateTime.parse(appointmentData['appointmentDate']);

    final appointmentTime = appointmentData['appointmentTime'] ?? '00:00';

    final status = appointmentData['status'] ?? 'pending';

    final paymentMethod = appointmentData['paymentMethod'] ?? 'Cash';

    final notes = appointmentData['notes'] ?? '';

    // =========================
    // PATIENT
    // =========================
    final patient = appointmentData['patient'] ?? {};

    final patientName = patient['name'] ?? 'Patient';

    final statusColor = _statusColor(status);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,

        centerTitle: true,

        title: const Text(
          'Appointment Details',

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),

          onPressed: () {
            Navigator.pop(context);
          },
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
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),

        child: Column(
          children: [
            _buildStatusBanner(status, statusColor),

            const SizedBox(height: 16),

            _buildDoctorSection(doctorName, doctorSpecialty),

            _buildAppointmentSection(
              appointmentDate,
              appointmentTime,
              clinicLocation,
            ),

            _buildPaymentSection(fees, paymentMethod),

            _buildPatientSection(patientName),

            if (notes.toString().isNotEmpty) _buildNotesSection(notes),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // =====================================
  // STATUS BANNER
  // =====================================
  Widget _buildStatusBanner(String status, Color color) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),

      decoration: BoxDecoration(
        color: color,

        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),

            blurRadius: 12,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        children: [
          Icon(_statusIcon(status), size: 58, color: Colors.white),

          const SizedBox(height: 10),

          Text(
            status.toUpperCase(),

            style: const TextStyle(
              fontWeight: FontWeight.bold,

              fontSize: 22,

              color: Colors.white,

              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Appointment ID: ${appointmentId.substring(0, 8).toUpperCase()}',

            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // =====================================
  // DOCTOR SECTION
  // =====================================
  Widget _buildDoctorSection(String doctorName, String doctorSpecialty) {
    return _CustomCard(
      title: 'Doctor Information',

      icon: Icons.person,

      child: Column(
        children: [
          CircleAvatar(
            radius: 38,

            backgroundColor: AppColors.primary.withOpacity(0.1),

            child: Text(
              doctorName.isNotEmpty ? doctorName[0] : 'D',

              style: TextStyle(
                fontSize: 32,

                fontWeight: FontWeight.bold,

                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(doctorName, style: AppText.h2, textAlign: TextAlign.center),

          const SizedBox(height: 6),

          Text(
            doctorSpecialty,

            style: AppText.body,

            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // =====================================
  // APPOINTMENT SECTION
  // =====================================
  Widget _buildAppointmentSection(DateTime date, String time, String location) {
    return _CustomCard(
      title: 'Appointment Details',

      icon: Icons.calendar_month_rounded,

      child: Column(
        children: [
          _DetailRow(
            icon: Icons.calendar_today_rounded,

            label: 'Date',

            value: _formatDate(date),

            color: AppColors.primary,
          ),

          const SizedBox(height: 16),

          _DetailRow(
            icon: Icons.access_time_rounded,

            label: 'Time',

            value: _formatTime(time),

            color: Colors.orange,
          ),

          const SizedBox(height: 16),

          _DetailRow(
            icon: Icons.location_on_rounded,

            label: 'Location',

            value: location,

            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  // =====================================
  // PAYMENT SECTION
  // =====================================
  Widget _buildPaymentSection(double fees, String paymentMethod) {
    final isCash = paymentMethod.toLowerCase() == 'cash';

    return _CustomCard(
      title: 'Payment Information',

      icon: Icons.payment_rounded,

      child: Column(
        children: [
          _DetailRow(
            icon: Icons.monetization_on_rounded,

            label: 'Consultation Fee',

            value: '${fees.toStringAsFixed(0)} EGP',

            color: Colors.green,
          ),

          const SizedBox(height: 16),

          _DetailRow(
            icon: isCash ? Icons.money_rounded : Icons.credit_card_rounded,

            label: 'Payment Method',

            value: paymentMethod,

            color: isCash ? Colors.green : Colors.blue,
          ),
        ],
      ),
    );
  }

  // =====================================
  // PATIENT SECTION
  // =====================================
  Widget _buildPatientSection(String patientName) {
    return _CustomCard(
      title: 'Patient Information',

      icon: Icons.person_outline_rounded,

      child: _DetailRow(
        icon: Icons.person_rounded,

        label: 'Patient Name',

        value: patientName,

        color: Colors.indigo,
      ),
    );
  }

  // =====================================
  // NOTES SECTION
  // =====================================
  Widget _buildNotesSection(String notes) {
    return _CustomCard(
      title: 'Notes',

      icon: Icons.notes_rounded,

      child: Text(notes, style: AppText.body),
    );
  }
}

// =========================================
// CUSTOM CARD
// =========================================
class _CustomCard extends StatelessWidget {
  final String title;

  final IconData icon;

  final Widget child;

  const _CustomCard({
    required this.title,

    required this.icon,

    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),

      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),

            blurRadius: 10,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),

                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),

                const SizedBox(width: 12),

                Text(title, style: AppText.h3),
              ],
            ),

            const SizedBox(height: 20),

            child,
          ],
        ),
      ),
    );
  }
}

// =========================================
// DETAIL ROW
// =========================================
class _DetailRow extends StatelessWidget {
  final IconData icon;

  final String label;

  final String value;

  final Color color;

  const _DetailRow({
    required this.icon,

    required this.label,

    required this.value,

    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),

          decoration: BoxDecoration(
            color: color.withOpacity(0.1),

            borderRadius: BorderRadius.circular(12),
          ),

          child: Icon(icon, size: 22, color: color),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(label, style: AppText.caption),

              const SizedBox(height: 4),

              Text(value, style: AppText.h3.copyWith(fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }
}
