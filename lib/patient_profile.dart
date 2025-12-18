import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final dobController = TextEditingController();
  final nameController = TextEditingController();

  final Map<String, Map<String, dynamic>> medicalSelected = {
    'Hypertension': {'checked': false, 'year': '2022', 'status': 'Edit'},
    'Type 2 Diabetes': {'checked': false, 'year': '2021', 'status': 'Edit'},
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _firebaseServices.getUserData();
      if (userData != null) {
        setState(() {
          nameController.text = userData['name'] ?? '';
          emailController.text = userData['email'] ?? '';
          phoneController.text = userData['phone'] ?? '';
          locationController.text = userData['location'] ?? '';
          dobController.text = userData['dateOfBirth'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    dobController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void changeAvatar() => setState(
    () => avatarColor = avatarColor == Colors.blue ? Colors.red : Colors.blue,
  );

  Future<void> saveForm() async {
    String dob = dobController.text.trim();
    String loc = locationController.text.trim();
    String phone = phoneController.text.trim();
    String name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name is required ⚠️')));
      return;
    }

    if (dob.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Date of Birth is required ⚠️')),
      );
      return;
    }
    if (loc.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Location is required ⚠️')));
      return;
    }
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is required ⚠️')),
      );
      return;
    } else if (phone.length != 11 || int.tryParse(phone) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number must be 11 digits ⚠️')),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isSaving = true;
      });

      try {
        final userId = _firebaseServices.getCurrentUserId();
        if (userId != null) {
          bool success = await _firebaseServices.updatePatientProfile(userId, {
            'name': name,
            'phone': phone,
            'location': loc,
            'dateOfBirth': dob,
          });

          if (!mounted) return;

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully! ✅')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update profile ⚠️')),
            );
          }
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()} ⚠️')));
      } finally {
        if (mounted) {
          setState(() {
            isSaving = false;
          });
        }
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fix errors ⚠️')));
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
              // Header
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

              // Info Card
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
                        infoField(
                          Icons.person,
                          'Name',
                          nameController,
                          (v) => (v == null || v.isEmpty)
                              ? 'Name is required'
                              : null,
                        ),
                        const Divider(),
                        infoField(
                          Icons.email,
                          'Email',
                          emailController,
                          (v) =>
                              (v == null ||
                                  !v.contains('@') ||
                                  !v.contains('.'))
                              ? 'Enter valid email'
                              : null,
                          enabled: false, // Email shouldn't be editable
                        ),
                        const Divider(),
                        infoField(
                          Icons.phone,
                          'Phone',
                          phoneController,
                          (v) =>
                              (v == null ||
                                  v.length != 11 ||
                                  int.tryParse(v) == null)
                              ? 'Phone must be 11 digits'
                              : null,
                        ),
                        const Divider(),
                        infoField(
                          Icons.location_on,
                          'Location',
                          locationController,
                          null,
                        ),
                        const Divider(),
                        infoField(
                          Icons.calendar_today,
                          'Date of Birth',
                          dobController,
                          null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Medical Conditions
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
                          String c = e.key;
                          bool sel = e.value['checked'];
                          String year = e.value['year'];
                          String status = e.value['status'];
                          return CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            value: sel,
                            onChanged: (v) => setState(
                              () => medicalSelected[c]!['checked'] = v!,
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: sel,
                                      onChanged: (v) => setState(
                                        () =>
                                            medicalSelected[c]!['checked'] = v!,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          year,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    String? newYear = await showDialog(
                                      context: context,
                                      builder: (ctx) => YearDialog(year: year),
                                    );
                                    if (newYear != null) {
                                      setState(
                                        () => medicalSelected[c]!['year'] =
                                            newYear,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: sel
                                        ? Colors.teal
                                        : Colors.grey,
                                  ),
                                  child: Text(
                                    status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Past Appointments - Firebase Integration
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
                          'Past Appointments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        StreamBuilder<QuerySnapshot>(
                          stream: _firebaseServices
                              .getPatientCompletedAppointments(
                                _firebaseServices.getCurrentUserId() ?? '',
                              ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(
                                    color: Colors.teal,
                                  ),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return const Center(
                                child: Text('Error loading appointments'),
                              );
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text('No past appointments'),
                                ),
                              );
                            }

                            final appointments = snapshot.data!.docs
                                .take(3)
                                .toList();

                            return Column(
                              children: appointments.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final timestamp =
                                    data['appointmentDate'] as Timestamp;
                                final date = timestamp.toDate();
                                final dateStr =
                                    '${date.month}/${date.day}/${date.year}';

                                return AppointmentCard(
                                  doctorName: data['doctorName'] ?? 'Doctor',
                                  specialization:
                                      data['doctorSpecialty'] ?? 'General',
                                  date: dateStr,
                                );
                              }).toList(),
                            );
                          },
                        ),
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
    TextEditingController c,
    String? Function(String?)? validator, {
    bool enabled = true,
  }) {
    return TextFormField(
      controller: c,
      validator: validator,
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

class YearDialog extends StatefulWidget {
  final String year;
  const YearDialog({super.key, required this.year});
  @override
  State<YearDialog> createState() => _YearDialogState();
}

class _YearDialogState extends State<YearDialog> {
  late TextEditingController controller;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.year);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Year'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final String doctorName;
  final String specialization;
  final String date;
  const AppointmentCard({
    super.key,
    required this.doctorName,
    required this.specialization,
    required this.date,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  specialization,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            Text(date, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
