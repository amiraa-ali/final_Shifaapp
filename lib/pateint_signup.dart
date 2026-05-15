import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import 'package:shifa/Services/auth_service.dart';

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

  // ✅ IMPORTANT
  final AuthService _authService = AuthService();

  bool isVisible = false;

  bool isLoading = false;

  // ====================
  // ERROR DIALOG
  // ====================
  void _showDialog({
    required String title,
    required String message,
    required DialogType type,
  }) {
    AwesomeDialog(
      context: context,

      dialogType: type,

      animType: AnimType.scale,

      title: title,

      desc: message,

      btnOkColor: Colors.teal,

      btnOkText: 'OK',
    ).show();
  }

  // ====================
  // SIGNUP
  // ====================
  Future<void> _handleSignup() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _authService.patientSignup(
        name: nameController.text.trim(),

        email: emailController.text.trim(),

        phone: phoneController.text.trim(),

        password: passwordController.text,
      );

      if (!mounted) return;

      AwesomeDialog(
        context: context,

        dialogType: DialogType.success,

        animType: AnimType.bottomSlide,

        title: 'Account Created 🎉',

        desc: 'Your account has been created successfully.',

        btnOkColor: Colors.teal,

        btnOkOnPress: () {
          Navigator.pushReplacement(
            context,

            MaterialPageRoute(builder: (_) => const PatientLogin()),
          );
        },
      ).show();
    } catch (e) {
      if (!mounted) return;

      _showDialog(
        title: 'Signup Failed',

        message: e.toString().replaceAll('Exception: ', ''),

        type: DialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
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
                // =================
                // LOGO
                // =================
                Image.asset(
                  "images/logo.png",

                  height: 260,

                  width: 260,

                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 10),

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

                // NAME
                _buildInput(
                  controller: nameController,

                  hint: 'Full Name',

                  icon: Icons.person,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // EMAIL
                _buildInput(
                  controller: emailController,

                  hint: 'Email',

                  icon: Icons.email_outlined,

                  keyboardType: TextInputType.emailAddress,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }

                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Enter valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // PHONE
                _buildInput(
                  controller: phoneController,

                  hint: 'Phone Number',

                  icon: Icons.phone,

                  keyboardType: TextInputType.phone,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // PASSWORD
                _buildInput(
                  controller: passwordController,

                  hint: 'Password',

                  icon: Icons.lock_outline,

                  obscure: !isVisible,

                  suffix: IconButton(
                    onPressed: () {
                      setState(() {
                        isVisible = !isVisible;
                      });
                    },

                    icon: Icon(
                      isVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }

                    if (value.length < 6) {
                      return 'Minimum 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // CONFIRM PASSWORD
                _buildInput(
                  controller: confirmPasswordController,

                  hint: 'Confirm Password',

                  icon: Icons.lock_reset,

                  obscure: !isVisible,

                  validator: (value) {
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // SIGNUP BUTTON
                SizedBox(
                  width: double.infinity,

                  height: 55,

                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleSignup,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),

                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,

                            child: CircularProgressIndicator(
                              color: Colors.white,

                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Sign Up',

                            style: TextStyle(
                              color: Colors.white,

                              fontWeight: FontWeight.bold,

                              fontSize: 18,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 25),

                // LOGIN LINK
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    const Text(
                      'Already have an account? ',

                      style: TextStyle(color: Colors.grey),
                    ),

                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) => const PatientLogin(),
                          ),
                        );
                      },

                      child: const Text(
                        'Login',

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

  // ====================
  // INPUT FIELD
  // ====================
  Widget _buildInput({
    required TextEditingController controller,

    required String hint,

    required IconData icon,

    TextInputType keyboardType = TextInputType.text,

    bool obscure = false,

    Widget? suffix,

    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,

        borderRadius: BorderRadius.circular(30),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: TextFormField(
        controller: controller,

        keyboardType: keyboardType,

        obscureText: obscure,

        enabled: !isLoading,

        validator: validator,

        decoration: InputDecoration(
          hintText: hint,

          prefixIcon: Icon(icon, color: Colors.grey),

          suffixIcon: suffix,

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
