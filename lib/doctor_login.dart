import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shifa/Services/firebase_services.dart';
import 'package:shifa/doctor_home_screen.dart';
import '../forget_password.dart';
import 'doctor_signup.dart';

class DoctorLogin extends StatefulWidget {
  const DoctorLogin({super.key});

  @override
  State<DoctorLogin> createState() => _DoctorLoginState();
}

class _DoctorLoginState extends State<DoctorLogin> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isvisible = false;
  bool isLoading = false;

  final FirebaseServices _firebaseServices = FirebaseServices();

  Future<void> _handleLogin() async {
    // Basic validation
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter email and password"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final role = await _firebaseServices.doctorSignIn(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      if (role == 'doctor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This account is not registered as a doctor"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      String message = e.toString().replaceAll('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Column(
            children: [
              Container(
                alignment: Alignment.center,
                width: 500,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(75),
                ),
                child: Image.asset("images/logo.png"),
              ),

              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !isLoading,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  labelText: "Email",
                  hintText: "Enter your email",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: passwordController,
                obscureText: !isvisible,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Enter your password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isvisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isvisible = !isvisible;
                      });
                    },
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SetNewPasswordScreen(),
                            ),
                          );
                        },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(
            width: double.infinity,
            child: MaterialButton(
              onPressed: isLoading ? null : _handleLogin,
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
                      "Login",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ),

          const SizedBox(height: 20),

          InkWell(
            onTap: isLoading
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DoctorSignup()),
                    );
                  },
            child: Center(
              child: Text.rich(
                TextSpan(
                  text: "Don't have an account? ",
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    TextSpan(
                      text: "Sign Up",
                      style: TextStyle(
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.bold,
                      ),
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
}
