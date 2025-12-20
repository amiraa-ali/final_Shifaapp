import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shifa/Services/firebase_services.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  final FirebaseServices _firebaseServices = FirebaseServices();

  Color avatarColor = Colors.blue;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  bool isSaving = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final dobController = TextEditingController();

  // ✅ Medical Conditions (Check / Uncheck فقط)
  final Map<String, bool> medicalSelected = {
    'Hypertension': false,
    'Type 2 Diabetes': false,
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Live update للاسم فوق
    nameController.addListener(() {
      setState(() {});
    });
  }

  // ================= LOAD USER DATA =================
  Future<void> _loadUserData() async {
    try {
      final userData = await _firebaseServices.getUserData();
      final authUser = FirebaseAuth.instance.currentUser;

      setState(() {
        nameController.text = userData?['name'] ?? '';
        phoneController.text = userData?['phone'] ?? '';
        locationController.text = userData?['location'] ?? '';
        dobController.text = userData?['dateOfBirth'] ?? '';

        // Email من FirebaseAuth
        emailController.text = authUser?.email ?? '';

        // Medical Conditions من Firestore (لو متخزنة)
        if (userData?['medicalConditions'] != null) {
          medicalSelected
            ..clear()
            ..addAll(Map<String, bool>.from(userData!['medicalConditions']));
        }

        isLoading = false;
      });
    } catch (e) {
      isLoading = false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    dobController.dispose();
    super.dispose();
  }

  void changeAvatar() {
    setState(() {
      avatarColor = avatarColor == Colors.blue ? Colors.redAccent : Colors.blue;
    });
  }

  // ================= SAVE PROFILE =================
  Future<void> saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final userId = _firebaseServices.getCurrentUserId();
      if (userId != null) {
        await _firebaseServices.updatePatientProfile(userId, {
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'location': locationController.text.trim(),
          'dateOfBirth': dobController.text.trim(),

          // حفظ Medical Conditions
          'medicalConditions': medicalSelected,
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully ✅')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE2E0E0),
      floatingActionButton: isSaving
          ? const CircularProgressIndicator()
          : ElevatedButton(
              onPressed: saveForm,
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ================= HEADER =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff39ab4a), Color(0xff009f93)],
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: changeAvatar,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: avatarColor,
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      nameController.text.isEmpty
                          ? 'User'
                          : nameController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      emailController.text,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================= INFO CARD =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        infoField(Icons.person, 'Name', nameController),
                        const Divider(),
                        infoField(
                          Icons.email,
                          'Email',
                          emailController,
                          enabled: false,
                        ),
                        const Divider(),
                        infoField(Icons.phone, 'Phone', phoneController),
                        const Divider(),
                        infoField(
                          Icons.location_on,
                          'Location',
                          locationController,
                        ),
                        const Divider(),
                        infoField(
                          Icons.calendar_today,
                          'Date of Birth',
                          dobController,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= MEDICAL CONDITIONS =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Medical Conditions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...medicalSelected.entries.map((e) {
                          return CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            value: e.value,
                            onChanged: (v) {
                              setState(() {
                                medicalSelected[e.key] = v!;
                              });
                            },
                            title: Text(
                              e.key,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoField(
    IconData icon,
    String label,
    TextEditingController c, {
    bool enabled = true,
  }) {
    return TextFormField(
      controller: c,
      enabled: enabled,
      decoration: InputDecoration(
        prefixIcon: CircleAvatar(
          backgroundColor: Colors.teal[50],
          child: Icon(icon, color: Colors.teal),
        ),
        labelText: label,
        border: InputBorder.none,
      ),
    );
  }
}
