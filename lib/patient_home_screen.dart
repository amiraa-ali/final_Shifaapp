import 'package:flutter/material.dart';
import 'package:shifa/auth/patient_guard.dart';
import 'package:shifa/patient_appointment_screen.dart';
import 'package:shifa/services/firebase_services.dart';
import 'categories.dart' as cat;
import 'package:shifa/profile.dart';
import 'doctor_page.dart';
import 'package:shifa/setting_page.dart';
import 'package:shifa/auth/welcome.dart';
import 'doctor_card.dart';
import 'patient_chat_screen.dart';
import 'patient_appointment_screen.dart';

// ================= MODEL =================
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

// ================= FAKE DOCTORS (UI ONLY) =================
final List<Map<String, dynamic>> doctorslist = [
  {
    'name': 'Dr. Sarah Johnson',
    'specialty': 'Cardiologist',
    'rating': 4.9,
    'yearsExp': 12.0,
    'location': 'City Hospital',
    'distance': 2.5,
    'imagePath': 'assets/images/doc1.png',
    'price': 300.0,
  },
  {
    'name': 'Dr. Michael Chen',
    'specialty': 'Orthopedic Surgeon',
    'rating': 4.8,
    'yearsExp': 15.0,
    'location': 'Memorial Clinic',
    'distance': 1.8,
    'imagePath': 'assets/images/doc2.png',
    'price': 300.0,
  },
  {
    'name': 'Dr. Emily Roberts',
    'specialty': 'General Physician',
    'rating': 4.7,
    'yearsExp': 8.0,
    'location': 'Health Center',
    'distance': 3.1,
    'imagePath': 'assets/images/doc3.png',
    'price': 300.0,
  },
];

// ================= PATIENT HOME =================
class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int index = 0;
  int _categoryIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 🔑 Bottom Nav Pages
  final List<Widget> pages = [
    const SizedBox.shrink(),
    ChatScreen(),
    PatientAppointmentsScreen(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return PatientGuard(
      child: Scaffold(
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
      ),
    );
  }

  // ================= HOME UI =================
  Widget _buildHomeUI() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderAndCategories(),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 10),
            child: const Text(
              'Available Doctors',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          ...doctorslist.map(
            (doc) => DoctorCard(
              name: doc['name'],
              specialty: doc['specialty'],
              rating: (doc['rating'] as num).toDouble(),
              yearsExp: (doc['yearsExp'] as num).toInt(),
              location: doc['location'],
              distance: (doc['distance'] as num).toDouble(),
              imagePath: doc['imagePath'],
              price: (doc['price'] as num).toDouble(),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ================= DRAWER =================
  Widget _buildDrawer() {
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
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    'ZH',
                    style: TextStyle(
                      color: Color(0xFF1ABC9C),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Zeyad Hassanien',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  'zeyad.hassanien@example.com',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home_outlined, color: Color(0xFF1ABC9C)),
            title: const Text('Home'),
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
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout'),
            onTap: () async {
              await FirebaseServices().logout();

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

  // ================= HEADER + CATEGORIES =================
  Widget _buildHeaderAndCategories() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
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
            children: const [
              Text.rich(
                TextSpan(
                  text: 'Welcome back,\n',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  children: [
                    TextSpan(
                      text: 'Zeyad Hassanien',
                      style: TextStyle(
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
                  'ZH',
                  style: TextStyle(
                    color: Color(0xFF1ABC9C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // MENU + SEARCH
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
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(Icons.menu, color: Colors.grey[800]),
                ),
              ),
              Expanded(
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Find your doctor or clinic...',
                      hintStyle: TextStyle(color: Colors.grey),
                      icon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // CATEGORIES
        Positioned(
          top: 210,
          left: 0,
          right: 0,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: categories.asMap().entries.map((entry) {
                final i = entry.key;
                final category = entry.value;

                return GestureDetector(
                  onTap: () {
                    setState(() => _categoryIndex = i);

                    if (category.title.toLowerCase() == 'all') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const cat.AllCategoriesPage(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DoctorsPage(
                            categoryName: category.title,
                            doctors: doctors,
                          ),
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
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
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
