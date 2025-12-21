import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shifa/Services/firebase_services.dart';
import 'patient_login.dart';

class PateintSignup extends StatefulWidget {
  const PateintSignup({super.key});

  @override
  State<PateintSignup> createState() => _PateintSignupState();
}

class _PateintSignupState extends State<PateintSignup> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final FirebaseServices _firebaseServices = FirebaseServices();

  bool isVisible = false;
  bool isLoading = false;
  Timer? _emailCheckTimer;

  // ==================== ERROR DIALOG ====================
  void _showErrorDialog({
    required String title,
    required String message,
    DialogType type = DialogType.error,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: type,
      animType: AnimType.scale,
      title: title,
      desc: message,
      btnOkText: 'OK',
      btnOkColor: Colors.teal,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
      descTextStyle: const TextStyle(fontSize: 14, color: Colors.black87),
      buttonsTextStyle: const TextStyle(color: Colors.white),
    ).show();
  }

  // ==================== EMAIL VERIFICATION DIALOG ====================
  void _showEmailVerificationDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: 'Verify Your Email 📧',
      desc:
          'Please verify your email address to continue. Check your inbox for the verification link.',
      btnOkText: 'Send Verification Email',
      btnOkColor: Colors.teal,
      btnCancelText: 'I\'ll do it later',
      btnCancelColor: Colors.grey,
      btnCancelOnPress: () {
        _firebaseServices.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PatientLogin()),
        );
      },
      btnOkOnPress: () => _sendVerificationEmail(),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
      descTextStyle: const TextStyle(fontSize: 14, color: Colors.black87),
      buttonsTextStyle: const TextStyle(color: Colors.white),
    ).show();
  }

  Future<void> _sendVerificationEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        if (!mounted) return;
        _showWaitingForVerificationDialog();
      }
    } catch (e) {
      if (!mounted) return;

      _showErrorDialog(
        title: 'Error',
        message: 'Failed to send verification email. Please try again.',
        type: DialogType.error,
      );
    }
  }

  void _showWaitingForVerificationDialog() {
    _startEmailVerificationCheck();

    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: 'Email Sent! ✉️',
      desc:
          'Verification email sent! Please check your inbox and click the verification link. This dialog will close automatically once verified.',
      btnOkText: 'I Verified My Email',
      btnOkColor: Colors.teal,
      btnCancelText: 'Resend Email',
      btnCancelColor: Colors.orange,
      btnCancelOnPress: () => _sendVerificationEmail(),
      btnOkOnPress: () => _checkVerificationManually(),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
      descTextStyle: const TextStyle(fontSize: 14, color: Colors.black87),
      buttonsTextStyle: const TextStyle(color: Colors.white),
      onDismissCallback: (type) => _emailCheckTimer?.cancel(),
    ).show();
  }

  void _startEmailVerificationCheck() {
    _emailCheckTimer?.cancel();

    _emailCheckTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      await _checkEmailVerification();
    });
  }

  Future<void> _checkEmailVerification() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        _emailCheckTimer?.cancel();

        if (!mounted) return;

        Navigator.of(context, rootNavigator: true).pop();
        _showVerificationSuccessDialog();
      }
    } catch (e) {
      print('Error checking verification: $e');
    }
  }

  Future<void> _checkVerificationManually() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      user = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (user != null && user.emailVerified) {
        _emailCheckTimer?.cancel();
        _showVerificationSuccessDialog();
      } else {
        _showErrorDialog(
          title: 'Not Verified Yet',
          message:
              'Please check your email and click the verification link, then try again.',
          type: DialogType.warning,
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showErrorDialog(
        title: 'Error',
        message: 'Failed to check verification status. Please try again.',
        type: DialogType.error,
      );
    }
  }

  void _showVerificationSuccessDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'Email Verified! ✅',
      desc:
          'Your email has been successfully verified. Redirecting to login...',
      btnOkColor: Colors.teal,
      autoHide: const Duration(seconds: 3),
      onDismissCallback: (_) {
        _firebaseServices.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PatientLogin()),
        );
      },
    ).show();
  }

  // ==================== SIGNUP HANDLER ====================
  Future<void> _handleSignup() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await _firebaseServices.patientSignUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
      );

      if (!mounted) return;

      _showEmailVerificationDialog();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String title = 'Signup Failed';
      String message = 'Failed to create account';
      DialogType dialogType = DialogType.error;

      switch (e.code) {
        case 'email-already-in-use':
          title = 'Email Already Registered';
          message =
              'This email is already registered. Please login or use a different email.';
          dialogType = DialogType.warning;
          break;

        case 'invalid-email':
          title = 'Invalid Email';
          message = 'Please enter a valid email address';
          dialogType = DialogType.info;
          break;

        case 'weak-password':
          title = 'Weak Password';
          message = 'Password should be at least 6 characters long';
          dialogType = DialogType.warning;
          break;

        case 'network-request-failed':
          title = 'Network Error';
          message = 'Please check your internet connection and try again';
          dialogType = DialogType.warning;
          break;

        default:
          title = 'Signup Failed';
          message = 'An error occurred. Please try again.';
      }

      _showErrorDialog(title: title, message: message, type: dialogType);
    } catch (e) {
      if (!mounted) return;

      _showErrorDialog(
        title: 'Unexpected Error',
        message: e.toString().replaceAll('Exception: ', ''),
        type: DialogType.error,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ==================== SOCIAL SIGN UP ====================
  Future<void> _handleSocialSignUp(String provider) async {
    setState(() => isLoading = true);

    try {
      UserCredential? userCredential;

      switch (provider) {
        case 'google':
          userCredential = await _firebaseServices.signInWithGoogle();
          break;
        case 'facebook':
          userCredential = await _firebaseServices.signInWithFacebook();
          break;
        case 'linkedin':
          userCredential = await _firebaseServices.signInWithLinkedIn();
          break;
      }

      if (userCredential == null) {
        setState(() => isLoading = false);
        return;
      }

      if (!mounted) return;

      final userId = userCredential.user?.uid;
      if (userId == null) throw Exception('User ID not found');

      final role = await _firebaseServices.getUserRole(userId);

      if (role == 'patient') {
        // Patient already exists
        if (!mounted) return;

        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: 'Welcome Back! 👋',
          desc: 'Account already exists. Redirecting to login...',
          btnOkColor: Colors.teal,
          autoHide: const Duration(seconds: 2),
          onDismissCallback: (_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PatientLogin()),
            );
          },
        ).show();
      } else if (role == 'doctor') {
        await _firebaseServices.signOut();

        if (!mounted) return;

        _showErrorDialog(
          title: 'Account Exists',
          message: 'This account is registered as a doctor.',
          type: DialogType.warning,
        );
      } else {
        // Create new patient account
        final success = await _firebaseServices.createPatientFromSocialAuth(
          userCredential.user!,
        );

        if (!mounted) return;

        if (success) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            title: 'Account Created! 🎉',
            desc:
                'Your account has been successfully created. Redirecting to login...',
            btnOkColor: Colors.teal,
            autoHide: const Duration(seconds: 3),
            onDismissCallback: (_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PatientLogin()),
              );
            },
          ).show();
        } else {
          _showErrorDialog(
            title: 'Account Creation Failed',
            message: 'Failed to create patient account.',
            type: DialogType.error,
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      _showErrorDialog(
        title: '${provider.capitalize()} Sign Up Failed',
        message: e.toString().replaceAll('Exception: ', ''),
        type: DialogType.error,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailCheckTimer?.cancel();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ================= LOGO =================
                Image.asset(
                  "assets/logo remover.png",
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.health_and_safety,
                      size: 100,
                      color: Colors.teal,
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Create Account",
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Join us to book appointments",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 30),

                // ================= FULL NAME =================
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextFormField(
                    controller: nameController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      hintText: "Full Name",
                      prefixIcon: Icon(Icons.person, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Your name is required";
                      }
                      if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                        return "Enter a valid full name";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // ================= EMAIL =================
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      hintText: "Email",
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return "Enter a valid email address";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // ================= PHONE =================
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      hintText: "Phone Number",
                      prefixIcon: Icon(Icons.phone, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Phone number is required";
                      }
                      if (!RegExp(
                        r'^(010|011|012|015)[0-9]{8}$',
                      ).hasMatch(value)) {
                        return "Enter valid Egyptian phone (010/011/012/015)";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // ================= PASSWORD =================
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: !isVisible,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.grey,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(() => isVisible = !isVisible),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
                      }
                      if (value.length < 6) {
                        return "At least 6 characters";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // ================= CONFIRM PASSWORD =================
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextFormField(
                    controller: confirmPasswordController,
                    obscureText: !isVisible,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      prefixIcon: const Icon(
                        Icons.lock_reset,
                        color: Colors.grey,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(() => isVisible = !isVisible),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                    validator: (value) {
                      if (value != passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 30),

                // ================= SIGNUP BUTTON =================
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // ================= LOGIN LINK =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    InkWell(
                      onTap: isLoading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PatientLogin(),
                                ),
                              );
                            },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: isLoading ? Colors.grey : Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ================= DIVIDER =================
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Sign up with another account',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),

                const SizedBox(height: 20),

                // ================= SOCIAL SIGNUP BUTTONS =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton(
                      icon: FontAwesomeIcons.google,
                      color: const Color(0xFFDB4437),
                      onTap: () => _handleSocialSignUp('google'),
                    ),
                    const SizedBox(width: 15),
                    _socialButton(
                      icon: FontAwesomeIcons.facebook,
                      color: const Color(0xFF1877F2),
                      onTap: () => _handleSocialSignUp('facebook'),
                    ),
                    const SizedBox(width: 15),
                    _socialButton(
                      icon: FontAwesomeIcons.linkedin,
                      color: const Color(0xFF0A66C2),
                      onTap: () => _handleSocialSignUp('linkedin'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== SOCIAL BUTTON ====================
  Widget _socialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: FaIcon(icon, color: color, size: 24)),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
