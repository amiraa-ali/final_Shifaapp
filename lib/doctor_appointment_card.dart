import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:shifa/Services/appointment_service.dart';

class AppointmentCard extends StatefulWidget {
  final String appointmentId;

  final String patientName;

  final String specialty;

  final DateTime appointmentDate;

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
    required this.appointmentDate,
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

  Color get _statusColor {
    switch (widget.status) {
      case 'completed':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      default:
        return Colors.teal;
    }
  }

  // =========================
  // COMPLETE
  // =========================
  Future<void> _completeAppointment() async {
    setState(() {
      isUpdating = true;
    });

    try {
      await _appointmentService.completeAppointment(widget.appointmentId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Appointment completed"),

          backgroundColor: Colors.green,
        ),
      );

      widget.onUpdate();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  // =========================
  // CANCEL
  // =========================
  Future<void> _cancelAppointment() async {
    setState(() {
      isUpdating = true;
    });

    try {
      await _appointmentService.cancelAppointment(widget.appointmentId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Appointment cancelled"),

          backgroundColor: Colors.red,
        ),
      );

      widget.onUpdate();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
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
            // =====================
            // HEADER
            // =====================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Expanded(
                  child: Text(
                    widget.patientName,

                    style: const TextStyle(
                      fontSize: 16,

                      fontWeight: FontWeight.bold,
                    ),
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
                    widget.status.toUpperCase(),

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
              widget.specialty,

              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),

            const SizedBox(height: 12),

            const Divider(),

            // =====================
            // DATE + TIME
            // =====================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Expanded(
                  child: Wrap(
                    spacing: 10,

                    runSpacing: 8,

                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          const Icon(
                            Icons.calendar_today,

                            size: 16,

                            color: Colors.grey,
                          ),

                          const SizedBox(width: 6),

                          Text(
                            DateFormat(
                              'EEE, dd MMM yyyy',
                            ).format(widget.appointmentDate),

                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          const Icon(
                            Icons.access_time,

                            size: 16,

                            color: Colors.grey,
                          ),

                          const SizedBox(width: 4),

                          Text(
                            widget.time,

                            style: const TextStyle(
                              fontSize: 14,

                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Text(
                  '${widget.fees.toStringAsFixed(0)} EGP',

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,

                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // =====================
            // PAYMENT
            // =====================
            Text(
              'Payment: ${widget.paymentMethod}',

              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),

            // =====================
            // ACTIONS
            // =====================
            if (widget.tabType != 'completed' && widget.tabType != 'cancelled')
              Padding(
                padding: const EdgeInsets.only(top: 16),

                child: isUpdating
                    ? const Center(child: CircularProgressIndicator())
                    : Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _completeAppointment,

                              icon: const Icon(Icons.check_circle),

                              label: const Text("Complete"),

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,

                                foregroundColor: Colors.white,

                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _cancelAppointment,

                              icon: const Icon(Icons.cancel),

                              label: const Text("Cancel"),

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,

                                foregroundColor: Colors.white,

                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
