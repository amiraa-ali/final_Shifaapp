import 'package:flutter/material.dart';
import 'package:shifa/patient_home_screen.dart';
import 'package:shifa/doctor_page.dart';

class AllCategoriesPage extends StatelessWidget {
  const AllCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> allCategories = [
      {
        "name": "General",
        "icon": Icons.medical_services,
        "color": const Color(0xff009688),
      },
      {
        "name": "Cardiology",
        "icon": Icons.favorite,
        "color": const Color(0xffFF6F91),
      },
      {
        "name": "Dermatology",
        "icon": Icons.face,
        "color": const Color(0xff845EC2),
      },
      {
        "name": "Neurology",
        "icon": Icons.psychology,
        "color": const Color(0xff0081CF),
      },
      {
        "name": "Pediatrics",
        "icon": Icons.child_care,
        "color": const Color(0xffF9A825),
      },
      {
        "name": "Orthopedics",
        "icon": Icons.accessibility_new,
        "color": const Color(0xff00C9A7),
      },
      {
        "name": "Psychology",
        "icon": Icons.psychology_alt,
        "color": const Color(0xffFF8A65),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
            );
          },
        ),
        title: const Text(
          "All Categories",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff39ab4a), Color(0xff009f93)],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: GridView.builder(
          itemCount: allCategories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.83,
          ),
          itemBuilder: (context, index) {
            final item = allCategories[index];

            return GestureDetector(
              onTap: () {
                // Navigate to doctors page filtered by this specialty
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorsPage(categoryName: item["name"]),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 12,
                      offset: const Offset(3, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Circle with gradient around icon
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            (item["color"] as Color).withOpacity(0.8),
                            (item["color"] as Color).withOpacity(0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(item["icon"], color: Colors.white, size: 30),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      item["name"],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
