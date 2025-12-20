import 'package:flutter/material.dart';
import 'package:shifa/patient_login.dart';
import 'package:shifa/doctor_login.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: WelcomeScreen()),
  );
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.white),

          Positioned(
            top: 50,
            left: 30,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal.withOpacity(0.1),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 50,
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.teal.withOpacity(0.08),
            ),
          ),
          Positioned(
            top: 150,
            right: 80,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.teal.withOpacity(0.12),
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("images/logo.png", fit: BoxFit.cover),
                const SizedBox(height: 10),
                const Text(
                  "Your Smart Health Companion",
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),

                // ------------------- زرار Login ---------------------
                SizedBox(
                  width: 220,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PatientLogin(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      "Continue as a Patient",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ------------------- زرار Signup ---------------------
                SizedBox(
                  width: 220,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DoctorLogin(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.teal),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      "Coninue as a Doctor",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}