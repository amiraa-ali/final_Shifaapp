import 'package:flutter/material.dart';

import 'package:shifa/categories_card.dart';
import 'package:shifa/doctor_page.dart';
import 'package:shifa/patient_appointment_screen.dart';
import 'package:shifa/patient_profile.dart';
import 'package:shifa/doctor_card.dart';
import 'package:shifa/patient_chat_screen.dart';
import 'package:shifa/app_theme.dart';

import 'package:shifa/Services/doctor_service.dart';
import 'package:shifa/Services/auth_service.dart';

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
  final DoctorService _doctorService = DoctorService();

  final AuthService _authService = AuthService();

  int index = 0;

  int _categoryIndex = 0;

  List<dynamic> doctors = [];

  bool isLoading = true;

  String userName = 'Patient';

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  // =========================
  // LOAD DATA
  // =========================
  Future<void> _loadData() async {
    try {
      final doctorsResult = await _doctorService.getDoctors();

      final profile = await _authService.getPatientProfile();

      if (!mounted) return;

      setState(() {
        doctors = doctorsResult;

        userName = profile['name'] ?? 'Patient';

        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeUI(),

      const PatientChatScreen(),

      const MyAppointmentsScreen(),

      const PatientProfilePage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),

        child: pages[index],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: index,

        height: 72,

        backgroundColor: Colors.white,

        indicatorColor: AppColors.primary.withOpacity(0.15),

        onDestinationSelected: (i) {
          setState(() {
            index = i;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),

            selectedIcon: Icon(Icons.home, color: AppColors.primary),

            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.chat_outlined),

            selectedIcon: Icon(Icons.chat, color: AppColors.primary),

            label: 'Chat',
          ),

          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),

            selectedIcon: Icon(Icons.calendar_today, color: AppColors.primary),

            label: 'Appointments',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),

            selectedIcon: Icon(Icons.person, color: AppColors.primary),

            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // =========================
  // HOME UI
  // =========================
  Widget _buildHomeUI() {
    return SafeArea(
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _loadData,

              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    _buildHeader(),

                    const SizedBox(height: 22),

                    _buildSearchBar(),

                    const SizedBox(height: 22),

                    _buildCategories(),

                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 26, 20, 10),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Text(
                            'Top Doctors',

                            style: TextStyle(
                              fontSize: 22,

                              fontWeight: FontWeight.bold,

                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildDoctorsSection(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  // =========================
  // DOCTORS SECTION
  // =========================
  Widget _buildDoctorsSection() {
    if (doctors.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: doctors.take(5).map((doctor) {
        return DoctorCard(
          doctorId: doctor['_id'] ?? '',

          name: doctor['name'] ?? 'Doctor',

          specialty: doctor['specialization'] ?? 'General',

          rating: (doctor['rating'] ?? 4.5).toDouble(),

          yearsExp: doctor['yearsExperience'] ?? 1,

          location: doctor['clinicLocation'] ?? 'Clinic',

          distance: 5.0,

          imageUrl: doctor['profileImage'],

          price: (doctor['fees'] ?? 0).toDouble(),
        );
      }).toList(),
    );
  }

  // =========================
  // HEADER
  // =========================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),

      decoration: const BoxDecoration(
        gradient: AppColors.mainGradient,

        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),

          bottomRight: Radius.circular(30),
        ),
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Welcome Back 👋',

                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),

                const SizedBox(height: 6),

                Text(
                  userName,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.white,

                    fontWeight: FontWeight.bold,

                    fontSize: 26,
                  ),
                ),
              ],
            ),
          ),

          Hero(
            tag: 'patient-avatar',

            child: Container(
              width: 60,
              height: 60,

              decoration: BoxDecoration(
                color: Colors.white,

                shape: BoxShape.circle,

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),

                    blurRadius: 12,

                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              child: Center(
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'P',

                  style: const TextStyle(
                    fontSize: 26,

                    fontWeight: FontWeight.bold,

                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // SEARCH BAR
  // =========================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: InkWell(
        borderRadius: BorderRadius.circular(18),

        onTap: () {
          Navigator.push(
            context,

            MaterialPageRoute(builder: (_) => const DoctorsPage()),
          );
        },

        child: Container(
          height: 58,

          padding: const EdgeInsets.symmetric(horizontal: 18),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(18),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),

                blurRadius: 12,

                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey.shade600),

              const SizedBox(width: 12),

              Text(
                'Search doctors or clinics...',

                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // CATEGORIES
  // =========================
  Widget _buildCategories() {
    return SizedBox(
      height: 60,

      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),

        physics: const BouncingScrollPhysics(),

        scrollDirection: Axis.horizontal,

        itemCount: categories.length,

        itemBuilder: (context, i) {
          final category = categories[i];

          final isSelected = _categoryIndex == i;

          return GestureDetector(
            onTap: () {
              setState(() {
                _categoryIndex = i;
              });

              if (category.title.toLowerCase() == 'all') {
                Navigator.push(
                  context,

                  MaterialPageRoute(builder: (_) => const AllCategoriesPage()),
                );
              } else {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) => DoctorsPage(categoryName: category.title),
                  ),
                );
              }
            },

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),

              margin: const EdgeInsets.only(right: 12),

              padding: const EdgeInsets.symmetric(horizontal: 18),

              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,

                borderRadius: BorderRadius.circular(18),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),

                    blurRadius: 10,

                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Row(
                children: [
                  Icon(
                    category.icon,

                    size: 20,

                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    category.title,

                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade800,

                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================
  // EMPTY STATE
  // =========================
  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(30),

      child: Center(
        child: Text('No doctors available', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
