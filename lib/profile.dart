import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Color avatarColor = Colors.blue;
  // int _selectedIndex = 3;
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController(text: '$UserName@example.com');
  final phoneController = TextEditingController(text: '01234567890');
  final locationController = TextEditingController(text: 'New York, NY');
  final dobController = TextEditingController(text: 'Jan 15, 1988');
  final nameController = TextEditingController();

  final Map<String, Map<String, dynamic>> medicalSelected = {
    'Hypertension': {'checked': false, 'year': '2022', 'status': 'Managed'},
    'Type 2 Diabetes': {
      'checked': false,
      'year': '2021',
      'status': 'Controlled',
    },
  };

  @override
  void initState() {
    super.initState();
    nameController.text = emailController.text.split('@')[0];
    emailController.addListener(() {
      if (emailController.text.contains('@')) {
        setState(
          () => nameController.text = emailController.text.split('@')[0],
        );
      }
    });
  }

  void changeAvatar() => setState(
    () => avatarColor = avatarColor == Colors.blue ? Colors.red : Colors.blue,
  );
  // void onNavBarTapped(int index) => setState(() => _selectedIndex = index);

  void saveForm() {
    String dob = dobController.text.trim();
    String loc = locationController.text.trim();
    String phone = phoneController.text.trim();

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data is valid! ✅')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fix errors ⚠️')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E0E0),
      floatingActionButton: ElevatedButton(
        onPressed: saveForm,
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
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
                      nameController.text,
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
                          Icons.email,
                          'Email',
                          emailController,
                          (v) =>
                              (v == null ||
                                  !v.contains('@') ||
                                  !v.contains('.'))
                              ? 'Enter valid email'
                              : null,
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

              // Medical History
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
                        Row(
                          children: const [
                            Icon(Icons.medical_services, color: Colors.teal),
                            SizedBox(width: 10),
                            Text(
                              'Medical History',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Column(
                          children: medicalSelected.keys.map((c) {
                            bool sel = medicalSelected[c]!['checked'];
                            String year = medicalSelected[c]!['year'];
                            String status = medicalSelected[c]!['status'];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: sel,
                                        onChanged: (v) => setState(
                                          () => medicalSelected[c]!['checked'] =
                                              v,
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
                                        builder: (ctx) =>
                                            YearDialog(year: year),
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
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Past Appointments
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
                      children: const [
                        Text(
                          'Past Appointments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        AppointmentCard(
                          doctorName: 'Dr. Sarah Nabil',
                          specialization: 'Dermatology, Ophthalmology',
                          date: 'Oct 15, 2025',
                        ),
                        AppointmentCard(
                          doctorName: 'Dr. Mohamed Tawfeq',
                          specialization: 'Dentistry',
                          date: 'Sep 10, 2025',
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

      // bottomNavigationBar: SizedBox(
      //   height: 100,
      //   child: BottomNavigationBar(
      //     currentIndex: _selectedIndex,
      //     onTap: onNavBarTapped,
      //     type: BottomNavigationBarType.fixed,
      //     selectedItemColor: Colors.teal,
      //     unselectedItemColor: Colors.grey,
      //     iconSize: 28,
      //     items: const [
      //       BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Home"),
      //       BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: "Bookings"),
      //       BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: "Chat"),
      //       BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
      //     ],
      //   ),
      // ),
    );
  }

  Widget infoField(
    IconData icon,
    String label,
    TextEditingController c,
    String? Function(String?)? validator,
  ) {
    return TextFormField(
      controller: c,
      validator: validator,
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

class UserName {}

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
