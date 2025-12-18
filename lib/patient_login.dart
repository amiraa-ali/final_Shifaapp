import 'package:flutter/material.dart';
import 'pateint_signup.dart';
import 'patient_home_screen.dart';

class PatientLogin extends StatefulWidget {
  const PatientLogin({super.key});

  @override
  State<PatientLogin> createState() => _LoginPageState();
}

class _LoginPageState extends State<PatientLogin> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isvisible = false;
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
                  'assets/logo remover.png',
                  // fit:BoxFit.fill ,
                ),

                const SizedBox(height: 30),
                //////////////////////////////////////////////////////////////////
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
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
                      borderSide: const BorderSide(
                        color: Colors.teal,
                        width: 2,
                      ),
                    ),
                    labelText: "Email or Phone",
                    hintText: "Enter your email or phone number",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email or phone is required";
                    }

                    if (RegExp(r'^01[0-9]+$').hasMatch(value)) {
                      if (value.length != 11) {
                        return "Enter valid phone number";
                      }
                    } else if (RegExp(r'^[a-zA-Z0-9@._-]+$').hasMatch(value)) {
                      if (!value.contains('@') || !value.contains('.')) {
                        return "Enter valid email address";
                      }
                    } else {
                      return "Enter valid email or phone number";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),
                //////////////////////////////////////////////
                TextFormField(
                  controller: passwordController,
                  obscureText: !isvisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter your password",
                    prefixIcon: const Icon(Icons.lock_outline),
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
                      borderSide: const BorderSide(
                        color: Colors.teal,
                        width: 2,
                      ),
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
                  validator: (value) {
                    if (value!.isEmpty) return "Password is required";
                    if (value.length < 6) return "At least 6 characters";
                    return null;
                  },
                ),
                ////////////////////////////////////////////////////////////
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      //                      Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => const SetNewPasswordScreen()),
                      // );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /////////////////////////////////////////////
                SizedBox(
                  width: double.infinity,
                  child: MaterialButton(
                    onPressed: () {
                      // التحقق قبل الانتقال
                      if (formKey.currentState!.validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PatientHomeScreen(),
                          ),
                        );
                      } else {}
                    },
                    color: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                Container(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PateintSignup(),
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
}
