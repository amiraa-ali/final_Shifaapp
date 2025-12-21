import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shifa/Services/firebase_services.dart';
import 'package:shifa/doctor_login.dart';

class DoctorSignup extends StatefulWidget {
  const DoctorSignup({super.key});

  @override
  State<DoctorSignup> createState() => _DoctorSignupState();
}

class _DoctorSignupState extends State<DoctorSignup> {
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();

  final FirebaseServices _firebaseServices = FirebaseServices();

  bool isVisible = false;
  bool isLoading = false;
  Timer? _emailCheckTimer;

  // Selected specialty from dropdown
  String? selectedSpecialty;

  // List of specialties
  final List<String> specialties = [
    'General',
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Pediatrics',
    'Orthopedics',
    'Psychology',
  ];

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
        // Sign out and go to login
        _firebaseServices.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorLogin()),
        );
      },
      btnOkOnPress: () {
        _sendVerificationEmail();
      },
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
      descTextStyle: const TextStyle(fontSize: 14, color: Colors.black87),
      buttonsTextStyle: const TextStyle(color: Colors.white),
    ).show();
  }

  // ==================== SEND VERIFICATION EMAIL ====================
  Future<void> _sendVerificationEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        if (!mounted) return;

        // Show waiting dialog
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

  // ==================== WAITING FOR VERIFICATION DIALOG ====================
  void _showWaitingForVerificationDialog() {
    // Start checking email verification status
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
      btnCancelOnPress: () {
        _sendVerificationEmail();
      },
      btnOkOnPress: () {
        _checkVerificationManually();
      },
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
      descTextStyle: const TextStyle(fontSize: 14, color: Colors.black87),
      buttonsTextStyle: const TextStyle(color: Colors.white),
      onDismissCallback: (type) {
        _emailCheckTimer?.cancel();
      },
    ).show();
  }

  // ==================== START CHECKING EMAIL VERIFICATION ====================
  void _startEmailVerificationCheck() {
    _emailCheckTimer?.cancel();

    _emailCheckTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      await _checkEmailVerification();
    });
  }

  // ==================== CHECK EMAIL VERIFICATION ====================
  Future<void> _checkEmailVerification() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        _emailCheckTimer?.cancel();

        if (!mounted) return;

        // Close any open dialogs
        Navigator.of(context, rootNavigator: true).pop();

        // Show success dialog
        _showVerificationSuccessDialog();
      }
    } catch (e) {
      print('Error checking verification: $e');
    }
  }

  // ==================== CHECK VERIFICATION MANUALLY ====================
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

  // ==================== VERIFICATION SUCCESS DIALOG ====================
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
        _firebaseServices.signOut(); // Sign out so they can login fresh
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorLogin()),
        );
      },
    ).show();
  }

  // ==================== SIGNUP HANDLER ====================
  Future<void> _handleSignup() async {
    if (!formKey.currentState!.validate()) return;

    // Check if specialty is selected
    if (selectedSpecialty == null) {
      _showErrorDialog(
        title: 'Missing Specialty',
        message: 'Please select your medical specialty',
        type: DialogType.info,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Create doctor account
      await _firebaseServices.doctorSignUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: fullNameController.text.trim(),
        specialization: selectedSpecialty!,
        clinicLocation: 'Clinic', // Will be updated in profile
        fees: 200.0, // Default fee, will be updated in profile
      );

      if (!mounted) return;

      // Show email verification dialog
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

        case 'operation-not-allowed':
          title = 'Service Unavailable';
          message =
              'Email/password accounts are not enabled. Please contact support.';
          dialogType = DialogType.error;
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

  @override
  void dispose() {
    _emailCheckTimer?.cancel();
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ================= DECORATIVE CIRCLES =================
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.20),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -40,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 180,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ================= MAIN CONTENT =================
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    SizedBox(
                      height: 150,
                      child: Image.asset(
                        "images/logo.png",
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.medical_services,
                            size: 100,
                            color: Colors.teal,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Create Doctor Account",
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Join our medical platform",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 30),

                    // ================= FULL NAME =================
                    TextFormField(
                      controller: fullNameController,
                      enabled: !isLoading,
                      decoration: _inputDecoration(
                        label: "Full Name",
                        hint: "Dr. Your Full Name",
                        icon: Icons.person,
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
                    const SizedBox(height: 15),

                    // ================= EMAIL =================
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                      decoration: _inputDecoration(
                        label: "Email",
                        hint: "Enter your email",
                        icon: Icons.email_outlined,
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
                    const SizedBox(height: 15),

                    // ================= PHONE =================
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      enabled: !isLoading,
                      decoration: _inputDecoration(
                        label: "Phone Number",
                        hint: "Enter your phone number",
                        icon: Icons.phone,
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
                    const SizedBox(height: 15),

                    // ================= SPECIALTY DROPDOWN =================
                    DropdownButtonFormField<String>(
                      value: selectedSpecialty,
                      decoration: _inputDecoration(
                        label: "Specialty",
                        hint: "Select your specialty",
                        icon: Icons.medical_services,
                      ),
                      items: specialties.map((String specialty) {
                        return DropdownMenuItem<String>(
                          value: specialty,
                          child: Text(specialty),
                        );
                      }).toList(),
                      onChanged: isLoading
                          ? null
                          : (String? newValue) {
                              setState(() => selectedSpecialty = newValue);
                            },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select a specialty";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // ================= PASSWORD =================
                    TextFormField(
                      controller: passwordController,
                      obscureText: !isVisible,
                      enabled: !isLoading,
                      decoration: _inputDecoration(
                        label: "Password",
                        hint: "Enter your password",
                        icon: Icons.lock_outline,
                        suffix: IconButton(
                          icon: Icon(
                            isVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() => isVisible = !isVisible);
                          },
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
                    const SizedBox(height: 15),

                    // ================= CONFIRM PASSWORD =================
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: !isVisible,
                      enabled: !isLoading,
                      decoration: _inputDecoration(
                        label: "Confirm Password",
                        hint: "Re-enter your password",
                        icon: Icons.lock_reset,
                        suffix: IconButton(
                          icon: Icon(
                            isVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() => isVisible = !isVisible);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value != passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),

                    // ================= SIGNUP BUTTON =================
                    SizedBox(
                      width: double.infinity,
                      child: MaterialButton(
                        onPressed: isLoading ? null : _handleSignup,
                        color: Colors.teal,
                        disabledColor: Colors.teal.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 16,
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
                        const Text("Already have an account? "),
                        InkWell(
                          onTap: isLoading
                              ? null
                              : () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const DoctorLogin(),
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== INPUT DECORATION ====================
  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.teal),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.teal),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
