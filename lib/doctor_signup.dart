import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import 'package:shifa/Services/auth_service.dart';
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

  final AuthService _authService = AuthService();

  bool isVisible = false;

  bool isLoading = false;

  // ====================
  // SPECIALTY
  // ====================
  String? selectedSpecialty;

  final List<String> specialties = [
    'General',
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Pediatrics',
    'Orthopedics',
    'Psychology',
  ];

  // ====================
  // DIALOG
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

      btnOkText: 'OK',

      btnOkColor: Colors.teal,
    ).show();
  }

  // ====================
  // SIGNUP
  // ====================
  Future<void> _handleSignup() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedSpecialty == null) {
      _showDialog(
        title: 'Missing Specialty',

        message: 'Please select your specialty',

        type: DialogType.info,
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _authService.doctorSignup(
        name: fullNameController.text.trim(),

        email: emailController.text.trim(),

        password: passwordController.text,

        phone: phoneController.text.trim(),

        specialization: selectedSpecialty!,

        clinicLocation: 'Clinic',

        fees: '200',
      );

      if (!mounted) return;

      AwesomeDialog(
        context: context,

        dialogType: DialogType.success,

        animType: AnimType.bottomSlide,

        title: 'Account Created 🎉',

        desc: 'Doctor account created successfully.',

        btnOkColor: Colors.teal,

        btnOkOnPress: () {
          Navigator.pushReplacement(
            context,

            MaterialPageRoute(builder: (_) => const DoctorLogin()),
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
          // =================
          // BACKGROUND
          // =================
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

          // =================
          // CONTENT
          // =================
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),

              child: Form(
                key: formKey,

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    // LOGO
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

                    // NAME
                    _buildInput(
                      controller: fullNameController,

                      label: "Full Name",

                      hint: "Dr. Your Name",

                      icon: Icons.person,

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Name is required";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    // EMAIL
                    _buildInput(
                      controller: emailController,

                      label: "Email",

                      hint: "Enter your email",

                      icon: Icons.email_outlined,

                      keyboardType: TextInputType.emailAddress,

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }

                        if (!value.contains('@') || !value.contains('.')) {
                          return "Enter valid email";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    // PHONE
                    _buildInput(
                      controller: phoneController,

                      label: "Phone Number",

                      hint: "Enter your phone",

                      icon: Icons.phone,

                      keyboardType: TextInputType.phone,

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Phone is required";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    // SPECIALTY
                    DropdownButtonFormField<String>(
                      value: selectedSpecialty,

                      decoration: _inputDecoration(
                        label: "Specialty",

                        hint: "Choose specialty",

                        icon: Icons.medical_services,
                      ),

                      items: specialties.map((specialty) {
                        return DropdownMenuItem(
                          value: specialty,

                          child: Text(specialty),
                        );
                      }).toList(),

                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                selectedSpecialty = value;
                              });
                            },
                    ),

                    const SizedBox(height: 15),

                    // PASSWORD
                    _buildInput(
                      controller: passwordController,

                      label: "Password",

                      hint: "Enter password",

                      icon: Icons.lock_outline,

                      obscure: !isVisible,

                      suffix: IconButton(
                        icon: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                        ),

                        onPressed: () {
                          setState(() {
                            isVisible = !isVisible;
                          });
                        },
                      ),

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password required";
                        }

                        if (value.length < 6) {
                          return "Minimum 6 chars";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    // CONFIRM
                    _buildInput(
                      controller: confirmPasswordController,

                      label: "Confirm Password",

                      hint: "Re-enter password",

                      icon: Icons.lock_reset,

                      obscure: !isVisible,

                      validator: (value) {
                        if (value != passwordController.text) {
                          return "Passwords don't match";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 35),

                    // BUTTON
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
                                width: 20,
                                height: 20,

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

                    // LOGIN
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

  // ====================
  // INPUT
  // ====================
  Widget _buildInput({
    required TextEditingController controller,

    required String label,

    required String hint,

    required IconData icon,

    TextInputType keyboardType = TextInputType.text,

    bool obscure = false,

    Widget? suffix,

    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,

      keyboardType: keyboardType,

      obscureText: obscure,

      enabled: !isLoading,

      validator: validator,

      decoration: _inputDecoration(
        label: label,

        hint: hint,

        icon: icon,

        suffix: suffix,
      ),
    );
  }

  // ====================
  // DECORATION
  // ====================
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

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),

        borderSide: const BorderSide(color: Colors.teal),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),

        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
    );
  }
}
