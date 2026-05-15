import 'package:flutter/material.dart';

import 'package:shifa/Services/auth_service.dart';
import 'package:shifa/Services/appointment_service.dart';

import 'welcome.dart';

class AppointmentChatGuard extends StatefulWidget {
  final String appointmentId;

  final Widget child;

  const AppointmentChatGuard({
    super.key,
    required this.appointmentId,
    required this.child,
  });

  @override
  State<AppointmentChatGuard> createState() => _AppointmentChatGuardState();
}

class _AppointmentChatGuardState extends State<AppointmentChatGuard> {
  final AppointmentService _appointmentService = AppointmentService();

  final AuthService _authService = AuthService();

  bool isLoading = true;

  bool hasAccess = false;

  @override
  void initState() {
    super.initState();

    _checkAccess();
  }

  // =========================
  // CHECK ACCESS
  // =========================
  Future<void> _checkAccess() async {
    try {
      final token = await _authService.getToken();

      if (token == null || token.isEmpty) {
        _denyAccess();
        return;
      }

      // =====================
      // GET APPOINTMENTS
      // =====================
      final patientAppointments = await _appointmentService
          .getPatientAppointments();

      final doctorAppointments = await _appointmentService
          .getDoctorAppointments();

      final allAppointments = [...patientAppointments, ...doctorAppointments];

      final appointment = allAppointments.firstWhere(
        (item) => item['_id'] == widget.appointmentId,

        orElse: () => null,
      );

      // =====================
      // NOT FOUND
      // =====================
      if (appointment == null) {
        _denyAccess();
        return;
      }

      // =====================
      // STATUS CHECK
      // =====================
      final status = appointment['status'] ?? '';

      final canChat =
          status == 'confirmed' ||
          status == 'completed' ||
          status == 'accepted' ||
          status == 'upcoming';

      if (!mounted) return;

      setState(() {
        hasAccess = canChat;

        isLoading = false;
      });

      if (!canChat) {
        _denyAccess();
      }
    } catch (e) {
      _denyAccess();
    }
  }

  // =========================
  // DENY ACCESS
  // =========================
  void _denyAccess() {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
        context,

        MaterialPageRoute(builder: (_) => const WelcomeScreen()),

        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // =====================
    // LOADING
    // =====================
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
    }

    // =====================
    // ACCESS GRANTED
    // =====================
    if (hasAccess) {
      return widget.child;
    }

    // =====================
    // ACCESS DENIED
    // =====================
    return const WelcomeScreen();
  }
}
