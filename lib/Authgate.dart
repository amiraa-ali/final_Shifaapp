import 'package:flutter/material.dart';

import 'package:shifa/Services/auth_service.dart';
import 'package:shifa/doctor_home_screen.dart';
import 'package:shifa/patient_home_screen.dart';
import 'package:shifa/welcome.dart';
import 'package:shifa/app_theme.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();

  late Future<String?> _tokenFuture;

  @override
  void initState() {
    super.initState();

    _tokenFuture = _initializeAuth();
  }

  Future<String?> _initializeAuth() async {
    try {
      final token = await _authService.getToken();

      return token;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _tokenFuture,

      builder: (context, snapshot) {
        // ============================================
        // LOADING
        // ============================================
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        // ============================================
        // NOT LOGGED IN
        // ============================================
        if (!snapshot.hasData || snapshot.data == null) {
          return const WelcomeScreen();
        }

        // ============================================
        // LOGGED IN
        // ============================================
        return const PatientHomeScreen();
      },
    );
  }
}

// =====================================================
// LOADING SCREEN
// =====================================================
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 90,
              height: 90,

              decoration: BoxDecoration(
                gradient: AppColors.mainGradient,

                shape: BoxShape.circle,

                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),

                    blurRadius: 18,

                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: const Icon(
                Icons.local_hospital,
                color: Colors.white,
                size: 42,
              ),
            ),

            const SizedBox(height: 28),

            const CircularProgressIndicator(color: AppColors.primary),

            const SizedBox(height: 18),

            Text(
              'Loading Shifa...',
              style: AppText.h3.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
