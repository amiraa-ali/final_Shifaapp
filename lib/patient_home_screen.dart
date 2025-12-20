import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shifa/categories_card.dart';
import 'package:shifa/doctor_page.dart';
import 'package:shifa/patient_profile.dart';
import 'package:shifa/setting_page.dart';
import 'package:shifa/Services/firebase_services.dart';
import 'package:shifa/doctor_card.dart';
import 'package:shifa/patient_chat_screen.dart';
import 'package:shifa/welcome.dart';

// Model
class Category {
  final String title;
  final IconData icon;
  Category(this.title, this.icon);
}

final List<Category> categories = [
  Category('All', Icons.monitor_heart),
  Category('Cardiology', Icons.favorite_border),
  Category('Orthopedic', Icons.airline_seat_legroom_extra),
  Category('General', Icons.local_hospital_outlined),
  Category('Pediatrics', Icons.child_care),
  Category('Dentistry', Icons.medical_services_outlined),
];

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final FirebaseServices _firebaseServices = FirebaseServices();
  int index = 0;
  int _categoryIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await _firebaseServices.getUserData();
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  final pages = [
    const SizedBox.shrink(),
    const PatientChatScreen(),
    const AllCategoriesPage(),
    const PatientProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],

      drawer: _buildDrawer(),

      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          setState(() {
            index = i;
          });
        },
        height: 60,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.teal),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat, color: Colors.teal),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today, color: Colors.teal),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person, color: Colors.teal),
            label: 'Profile',
          ),
        ],
      ),

      body: index == 0 ? _buildHomeUI() : pages[index],
    );
  }

  // HOME UI
  Widget _buildHomeUI() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderAndCategories(),

          const Padding(
            padding: EdgeInsets.fromLTRB(20, 80, 20, 10),
            child: Text(
              'Available Doctors',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // Real-time doctors from Firebase
          StreamBuilder<QuerySnapshot>(
            stream: _firebaseServices.getTopRatedDoctors(limit: 5),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: Colors.teal),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No doctors available'),
                  ),
                );
              }

              final doctors = snapshot.data!.docs;

              return Column(
                children: doctors.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return DoctorCard(
                    doctorId: doc.id,
                    name: data['name'] ?? 'Doctor',
                    specialty: data['specialization'] ?? 'General',
                    rating: (data['rating'] ?? 0.0).toDouble(),
                    yearsExp: data['yearsExperience'] ?? 0,
                    location: data['clinicLocation'] ?? 'Clinic',
                    distance: 5.0, // Default distance
                    imagePath: 'assets/images/doc1.png',
                    price: (data['fees'] ?? 0.0).toDouble(),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // DRAWER
  Widget _buildDrawer() {
    String userName = userData?['name'] ?? 'User';
    String userEmail = userData?['email'] ?? 'user@example.com';
    String initials = userName.isNotEmpty
        ? userName.split(' ').map((n) => n[0]).take(2).join().toUpperCase()
        : 'U';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2ECC71), Color(0xFF1ABC9C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Color(0xFF1ABC9C),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userName,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  userEmail,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home_outlined, color: Color(0xFF1ABC9C)),
            title: const Text('Home (Patient)'),
            onTap: () => Navigator.pop(context),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF1ABC9C),
            ),
            title: const Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),

         ListTile(
  leading: const Icon(Icons.logout, color: Colors.redAccent),
  title: const Text('Logout'),
  onTap: () async {
    // 1️⃣ اقفلي الـ Drawer
    Navigator.pop(context);

    // 2️⃣ Logout من Firebase
    await _firebaseServices.logout();

    if (!mounted) return;

    // 3️⃣ استني frame صغير (مهم)
    await Future.delayed(const Duration(milliseconds: 100));

    // 4️⃣ روحي للـ Welcome وامسحي كل اللي قبله
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  },
),

        ],
      ),
    );
  }

  // HEADER + CATEGORIES
  Widget _buildHeaderAndCategories() {
    String userName = userData?['name'] ?? 'User';
    String initials = userName.isNotEmpty
        ? userName.split(' ').map((n) => n[0]).take(2).join().toUpperCase()
        : 'U';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 150),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2ECC71), Color(0xFF1ABC9C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Welcome back,\n',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  children: [
                    TextSpan(
                      text: userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Color(0xFF1ABC9C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search + Menu
        Positioned(
          top: 125,
          left: 20,
          right: 20,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(Icons.menu, color: Colors.grey[800]),
                ),
              ),

              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to all doctors with search
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DoctorsPage()),
                    );
                  },
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 10),
                        Text(
                          'Find your doctor or clinic...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Categories
        Positioned(
          top: 210,
          left: 0,
          right: 0,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: categories.asMap().entries.map((entry) {
                int i = entry.key;
                Category category = entry.value;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _categoryIndex = i;
                    });

                    if (category.title.toLowerCase() == 'all') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllCategoriesPage(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DoctorsPage(categoryName: category.title),
                        ),
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 15),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _categoryIndex == i ? Colors.teal : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          category.icon,
                          color: _categoryIndex == i
                              ? Colors.white
                              : Colors.grey[800],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category.title,
                          style: TextStyle(
                            color: _categoryIndex == i
                                ? Colors.white
                                : Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}