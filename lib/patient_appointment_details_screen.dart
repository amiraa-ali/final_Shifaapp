import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final String appointmentId;
  final Map<String, dynamic> appointmentData;

  const AppointmentDetailsScreen({
    super.key,
    required this.appointmentId,
    required this.appointmentData,
  });

  // ==================== STATUS COLOR ====================
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ==================== FORMAT DATE ====================
  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }

  // ==================== FORMAT TIME ====================
  String _formatTime(String time) {
    try {
      final parsedTime = DateFormat('HH:mm').parse(time);
      return DateFormat('h:mm a').format(parsedTime);
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorName = appointmentData['doctorName'] ?? 'Doctor';
    final doctorSpecialty = appointmentData['doctorSpecialty'] ?? 'Specialist';
    final appointmentDate = (appointmentData['appointmentDate'] as Timestamp).toDate();
    final appointmentTime = appointmentData['appointmentTime'] ?? '00:00';
    final status = appointmentData['status'] ?? 'upcoming';
    final fees = (appointmentData['fees'] as num?)?.toDouble() ?? 0.0;
    final clinicLocation = appointmentData['clinicLocation'] ?? 'Clinic';
    final paymentMethod = appointmentData['paymentMethod'] ?? 'Cash';
    final patientName = appointmentData['patientName'] ?? 'Patient';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Appointment Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= STATUS BANNER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    status.toLowerCase() == 'upcoming'
                        ? Icons.upcoming
                        : status.toLowerCase() == 'completed'
                            ? Icons.check_circle
                            : Icons.cancel,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Appointment ID: ${appointmentId.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================= DOCTOR CARD =================
            _buildCard(
              title: 'Doctor Information',
              icon: Icons.person,
              child: Column(
                children: [
                  // Doctor Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        doctorName.isNotEmpty ? doctorName[0].toUpperCase() : 'D',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    doctorName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctorSpecialty,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // ================= APPOINTMENT DETAILS =================
            _buildCard(
              title: 'Appointment Details',
              icon: Icons.calendar_month,
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: _formatDate(appointmentDate),
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.access_time,
                    label: 'Time',
                    value: _formatTime(appointmentTime),
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: clinicLocation,
                    color: Colors.purple,
                  ),
                ],
              ),
            ),

            // ================= PAYMENT DETAILS =================
            _buildCard(
              title: 'Payment Information',
              icon: Icons.payment,
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.attach_money,
                    label: 'Consultation Fee',
                    value: '\$${fees.toStringAsFixed(2)}',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: paymentMethod.toLowerCase() == 'cash'
                        ? Icons.money
                        : Icons.credit_card,
                    label: 'Payment Method',
                    value: paymentMethod,
                    color: paymentMethod.toLowerCase() == 'cash'
                        ? Colors.green
                        : Colors.blue,
                  ),
                ],
              ),
            ),

            // ================= PATIENT INFO =================
            _buildCard(
              title: 'Patient Information',
              icon: Icons.person_outline,
              child: _buildDetailRow(
                icon: Icons.person,
                label: 'Patient Name',
                value: patientName,
                color: Colors.indigo,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ==================== BUILD CARD ====================
  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.teal.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  // ==================== BUILD DETAIL ROW ====================
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 24,
            color: color,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
