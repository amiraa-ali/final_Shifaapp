import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shifa/Services/firebase_services.dart';
import 'package:shifa/doctor_home_screen.dart';
import 'doctor_signup.dart';

class DoctorLogin extends StatefulWidget {
  const DoctorLogin({super.key});

  @override
  State<DoctorLogin> createState() => _DoctorLoginState();
}

class _DoctorLoginState extends State<DoctorLogin> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isVisible = false;
  bool isLoading = false;

  final FirebaseServices _firebaseServices = FirebaseServices();

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

  void _showSuccessDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'Welcome Doctor 👋',
      desc: 'Login successful. Redirecting...',
      btnOkColor: Colors.teal,
      autoHide: const Duration(seconds: 2),
      onDismissCallback: (_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
        );
      },
    ).show();
  }

  Future<void> _handleLogin() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final userCredential = await _firebaseServices.doctorSignIn(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      final userId = userCredential.user?.uid;
      if (userId == null) throw Exception('User ID not found');

      final role = await _firebaseServices.getUserRole(userId);

      if (!mounted) return;

      if (role == 'doctor') {
        _showSuccessDialog();
      } else {
        await _firebaseServices.signOut();
        _showErrorDialog(
          title: 'Access Denied',
          message: 'Please use the correct login type.',
          type: DialogType.warning,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Login failed';
      switch (e.code) {
        case 'user-not-found':
          message = 'No account exists with this email';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password';
          break;
        case 'network-request-failed':
          message = 'Check your internet connection';
          break;
      }

      _showErrorDialog(
        title: 'Login Failed',
        message: message,
        type: DialogType.error,
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(
        title: 'Unexpected Error',
        message: e.toString(),
        type: DialogType.error,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (emailController.text.isEmpty) {
      _showErrorDialog(
        title: 'Missing Email',
        message: 'Please enter your email first',
        type: DialogType.info,
      );
      return;
    }

    if (!emailController.text.contains('@') ||
        !emailController.text.contains('.')) {
      _showErrorDialog(
        title: 'Invalid Email',
        message: 'Please enter a valid email address',
        type: DialogType.info,
      );
      return;
    }

    try {
      await _firebaseServices.sendPasswordResetEmail(
        emailController.text.trim(),
      );

      if (!mounted) return;

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: 'Email Sent ✉️',
        desc: 'Password reset link has been sent to your email',
        btnOkColor: Colors.teal,
      ).show();
    } catch (e) {
      if (!mounted) return;

      _showErrorDialog(
        title: 'Error',
        message: 'Failed to send reset email. Please try again.',
        type: DialogType.error,
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
              children: [
                Image.asset(
                  "images/logo.png",
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.medical_services,
                    size: 100,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Doctor Login',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 30),

                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                  decoration: _inputDecoration(
                    label: "Email",
                    hint: "Enter your email",
                    icon: Icons.email,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email is required";
                    }
                    if (!value.contains('@')) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

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

                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: isLoading ? null : _resetPassword,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: isLoading ? Colors.grey : Colors.teal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  child: MaterialButton(
                    onPressed: isLoading ? null : _handleLogin,
                    color: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DoctorSignup(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.teal,
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
    );
  }

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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}
