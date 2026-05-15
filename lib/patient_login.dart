import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shifa/Services/auth_service.dart';
import 'package:shifa/patient_home_screen.dart';
import 'package:shifa/doctor_home_screen.dart';
import 'pateint_signup.dart';

class PatientLogin extends StatefulWidget {
  const PatientLogin({super.key});

  @override
  State<PatientLogin> createState() => _PatientLoginState();
}

class _PatientLoginState extends State<PatientLogin> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  bool isVisible = false;

  bool isLoading = false;

  final AuthService _authService = AuthService();

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
      btnOkText: "OK",
    ).show();
  }

  Future<void> _handleLogin() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = response["user"];

      final role = user["role"];

      if (!mounted) return;

      if (role == "patient") {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: "Welcome 👋",
          desc: "Login Successful",
          autoHide: const Duration(seconds: 2),
          btnOkColor: Colors.teal,
          onDismissCallback: (_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
            );
          },
        ).show();
      } else if (role == "doctor") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
        );
      } else {
        _showDialog(
          title: "Access Denied",
          message: "Invalid account type",
          type: DialogType.warning,
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showDialog(
        title: "Login Failed",
        message: "Incorrect email or password",
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
                  'images/logo.png',
                  height: 120,

                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.health_and_safety,
                    size: 100,
                    color: Colors.teal,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Patient Login',

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
                      return "Enter valid email";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: passwordController,

                  obscureText: !isVisible,

                  decoration: _inputDecoration(
                    label: "Password",

                    hint: "Enter your password",

                    icon: Icons.lock_outline,

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
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password is required";
                    }

                    if (value.length < 6) {
                      return "Minimum 6 characters";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,

                  child: MaterialButton(
                    onPressed: isLoading ? null : _handleLogin,

                    color: Colors.teal,

                    padding: const EdgeInsets.symmetric(vertical: 15),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Login",

                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    const Text("Don't have an account?"),

                    const SizedBox(width: 5),

                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PateintSignup(),
                          ),
                        );
                      },

                      child: const Text(
                        "Create Account",

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

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),

        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
    );
  }
}
