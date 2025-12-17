import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shifa/Services/firebase_services.dart';
import 'package:shifa/auth/doctor_signup.dart';
import 'package:shifa/doctor_home_screen.dart';
import '../forget_password.dart';

class DoctorLogin extends StatefulWidget {
  const DoctorLogin({super.key});

  @override
  State<DoctorLogin> createState() => _DoctorLoginState();
}

class _DoctorLoginState extends State<DoctorLogin> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isvisible = false;

  final FirebaseServices _firebaseServices = FirebaseServices();

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
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  labelText: "Email or Phone",
                  hintText: "Enter your email or phone number",
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
                  onPressed: () {
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
              onPressed: () async {
                try {
                  final role = await _firebaseServices.login(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  );

                  if (role == 'doctor') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DoctorHomeScreen(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("This account is not a doctor"),
                      ),
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  String message;
                  switch (e.code) {
                    case 'user-not-found':
                      message = "No user found for that email.";
                      break;
                    case 'wrong-password':
                      message = "Wrong password.";
                      break;
                    default:
                      message = "Login failed. Please try again.";
                  }

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message)));
                }
              },
              color: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Login",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 20),

          InkWell(
            onTap: () {
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
