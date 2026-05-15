import 'package:flutter/material.dart';

import 'package:shifa/Services/auth_service.dart';
import 'package:shifa/Services/appointment_service.dart';

class DoctorGuard extends StatefulWidget {
  final Widget child;

  const DoctorGuard({super.key, required this.child});

  @override
  State<DoctorGuard> createState() => _DoctorGuardState();
}

class _DoctorGuardState extends State<DoctorGuard> {
  final AuthService _authService = AuthService();

  bool isLoading = true;

  bool isAuthenticated = false;

  String role = '';

  @override
  void initState() {
    super.initState();

    _checkAuth();
  }

  // =========================
  // CHECK AUTH
  // =========================
  Future<void> _checkAuth() async {
    try {
      final token = await _authService.getToken();

      if (token == null || token.isEmpty) {
        _redirectToWelcome();
        return;
      }

      final profile = await _authService.getDoctorProfile();

      if (!mounted) return;

      setState(() {
        isAuthenticated = true;

        role = profile['role'] ?? 'doctor';

        isLoading = false;
      });

      // NOT DOCTOR
      if (role != 'doctor') {
        if (!mounted) return;

        Navigator.pushReplacementNamed(context, '/patient-home');
      }
    } catch (e) {
      _redirectToWelcome();
    }
  }

  // =========================
  // REDIRECT
  // =========================
  void _redirectToWelcome() {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
    }

    if (isAuthenticated && role == 'doctor') {
      return widget.child;
    }

    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Colors.teal)),
    );
  }
}

// ========================================================
// APPOINTMENT CHAT GUARD
// ========================================================

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

      if (token == null) {
        _redirect();
        return;
      }

      // هنا نفترض إن عندك API
      // appointment by id

      final appointments = await _appointmentService.getPatientAppointments();

      final appointment = appointments.firstWhere(
        (item) => item['_id'] == widget.appointmentId,

        orElse: () => null,
      );

      if (appointment == null) {
        _redirect();
        return;
      }

      final status = appointment['status'];

      final canChat = status == 'upcoming' || status == 'completed';

      if (!mounted) return;

      setState(() {
        hasAccess = canChat;

        isLoading = false;
      });

      if (!canChat) {
        _redirect();
      }
    } catch (e) {
      _redirect();
    }
  }

  // =========================
  // REDIRECT
  // =========================
  void _redirect() {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
    }

    if (hasAccess) {
      return widget.child;
    }

    return const Scaffold(body: Center(child: Text('Access denied')));
  }
}
