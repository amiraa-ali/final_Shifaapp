import 'package:flutter/material.dart';

import 'package:shifa/Services/auth_service.dart';

class PatientGuard extends StatefulWidget {
  final Widget child;

  const PatientGuard({super.key, required this.child});

  @override
  State<PatientGuard> createState() => _PatientGuardState();
}

class _PatientGuardState extends State<PatientGuard> {
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

      final profile = await _authService.getPatientProfile();

      if (!mounted) return;

      setState(() {
        isAuthenticated = true;

        role = profile['role'] ?? 'patient';

        isLoading = false;
      });

      // NOT PATIENT
      if (role != 'patient') {
        if (!mounted) return;

        Navigator.pushReplacementNamed(context, '/doctor-home');
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
    // =====================
    // LOADING
    // =====================
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
    }

    // =====================
    // AUTHENTICATED
    // =====================
    if (isAuthenticated && role == 'patient') {
      return widget.child;
    }

    // =====================
    // FALLBACK
    // =====================
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Colors.teal)),
    );
  }
}
