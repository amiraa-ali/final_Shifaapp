import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final String appointmentId;
  final String patientName;
  final String specialty;
  final DateTime appointmentDate; // ✅ جديد
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
    required this.appointmentDate, // ✅ جديد
    required this.time,
    required this.fees,
    required this.paymentMethod,
    required this.status,
    required this.tabType,
    required this.onUpdate,
  });

  Color get _statusColor {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient name + status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  patientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              specialty,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),

            const SizedBox(height: 12),
            const Divider(),

            // 📅 Date + Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('EEE, dd MMM yyyy').format(appointmentDate),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${fees.toStringAsFixed(0)} EGP',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Payment: $paymentMethod',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
