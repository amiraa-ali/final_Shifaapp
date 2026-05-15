import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_theme.dart';

class AppointmentCard extends StatelessWidget {
  final String appointmentId;

  final String doctorName;

  final String doctorSpecialty;

  final DateTime appointmentDate;

  final String appointmentTime;

  final String status;

  final double fees;

  final String clinicLocation;

  final String paymentMethod;

  final VoidCallback onTap;

  final VoidCallback? onCancel;

  const AppointmentCard({
    super.key,

    required this.appointmentId,

    required this.doctorName,

    required this.doctorSpecialty,

    required this.appointmentDate,

    required this.appointmentTime,

    required this.status,

    required this.fees,

    required this.clinicLocation,

    required this.paymentMethod,

    required this.onTap,

    this.onCancel,
  });

  // =========================
  // STATUS COLOR
  // =========================
  Color get _statusColor {
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
  IconData get _statusIcon {
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
        return Icons.info_rounded;
    }
  }

  // =========================
  // FORMAT DATE
  // =========================
  String _formatDate(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final d = DateTime(date.year, date.month, date.day);

    if (d == today) {
      return 'Today, ${DateFormat('dd/MM/yyyy').format(date)}';
    }

    if (d == tomorrow) {
      return 'Tomorrow, ${DateFormat('dd/MM/yyyy').format(date)}';
    }

    return DateFormat('EEE, dd/MM/yyyy').format(date);
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

      return DateFormat('h:mm a').format(parsed);
    } catch (_) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),

      elevation: 2,

      shadowColor: Colors.black12,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(16),

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // =========================
              // HEADER
              // =========================
              Row(
                children: [
                  Container(
                    width: 52,

                    height: 52,

                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),

                      shape: BoxShape.circle,
                    ),

                    child: Center(
                      child: Text(
                        doctorName.isNotEmpty
                            ? doctorName[0].toUpperCase()
                            : 'D',

                        style: TextStyle(
                          fontSize: 22,

                          fontWeight: FontWeight.bold,

                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          doctorName,

                          style: AppText.h3,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 2),

                        Text(
                          doctorSpecialty,

                          style: AppText.caption,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  _StatusBadge(
                    status: status,

                    color: _statusColor,

                    icon: _statusIcon,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Divider(color: AppColors.divider, height: 1),

              const SizedBox(height: 14),

              // =========================
              // DATE & TIME
              // =========================
              Row(
                children: [
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.calendar_today_rounded,

                      label: _formatDate(appointmentDate),

                      color: AppColors.primary,
                    ),
                  ),

                  Expanded(
                    child: _InfoChip(
                      icon: Icons.access_time_rounded,

                      label: _formatTime(appointmentTime),

                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // =========================
              // LOCATION & FEES
              // =========================
              Row(
                children: [
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.location_on_rounded,

                      label: clinicLocation,

                      color: Colors.purple,
                    ),
                  ),

                  Expanded(
                    child: _InfoChip(
                      icon: Icons.payments_rounded,

                      label: '${fees.toStringAsFixed(0)} EGP',

                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // =========================
              // BUTTONS
              // =========================
              Row(
                mainAxisAlignment: MainAxisAlignment.end,

                children: [
                  if (onCancel != null &&
                      status.toLowerCase() != 'cancelled' &&
                      status.toLowerCase() != 'completed')
                    OutlinedButton.icon(
                      onPressed: onCancel,

                      icon: const Icon(Icons.close_rounded, size: 16),

                      label: const Text("Cancel"),

                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,

                        side: const BorderSide(color: Colors.red),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                  const SizedBox(width: 10),

                  ElevatedButton.icon(
                    onPressed: onTap,

                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),

                    label: const Text('Details'),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,

                      foregroundColor: Colors.white,

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================
// STATUS BADGE
// ======================================
class _StatusBadge extends StatelessWidget {
  final String status;

  final Color color;

  final IconData icon;

  const _StatusBadge({
    required this.status,

    required this.color,

    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

      decoration: BoxDecoration(
        color: color.withOpacity(0.1),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: color.withOpacity(0.3)),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(icon, size: 14, color: color),

          const SizedBox(width: 4),

          Text(
            status.toUpperCase(),

            style: TextStyle(
              fontSize: 11,

              fontWeight: FontWeight.w600,

              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================
// INFO CHIP
// ======================================
class _InfoChip extends StatelessWidget {
  final IconData icon;

  final String label;

  final Color color;

  const _InfoChip({
    required this.icon,

    required this.label,

    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),

          decoration: BoxDecoration(
            color: color.withOpacity(0.1),

            borderRadius: BorderRadius.circular(7),
          ),

          child: Icon(icon, size: 14, color: color),
        ),

        const SizedBox(width: 6),

        Expanded(
          child: Text(
            label,

            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),

            maxLines: 1,

            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
