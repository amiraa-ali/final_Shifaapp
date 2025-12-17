import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shifa/Services/firebase_services.dart';
import 'package:shifa/auth/doctor_login.dart';

class DoctorSignup extends StatefulWidget {
  const DoctorSignup({super.key});

  @override
  State<DoctorSignup> createState() => _DoctorSignupState();
}

class _DoctorSignupState extends State<DoctorSignup> {
  final formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isvisible = false;

  final FirebaseServices _firebaseServices = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
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

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    SizedBox(height: 200, child: Image.asset("image/logo.png")),

                    const Text(
                      "Create your new account",
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Name required" : null,
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Email required" : null,
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: passwordController,
                      obscureText: !isvisible,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isvisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isvisible = !isvisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) =>
                          value!.length < 6 ? "Min 6 chars" : null,
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: MaterialButton(
                        color: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "Create Account",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          try {
                            await _firebaseServices.signUp(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                              role: 'doctor',
                              extraData: {
                                'name': _fullNameController.text.trim(),
                              },
                            );

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Doctor account created"),
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DoctorLogin(),
                              ),
                            );
                          } on FirebaseAuthException catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.message ?? "Error")),
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DoctorLogin(),
                              ),
                            );
                          },
                          child: const Text(
                            "Login",
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
        ],
      ),
    );
  }
}
