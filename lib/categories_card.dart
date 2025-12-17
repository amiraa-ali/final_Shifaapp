import 'package:flutter/material.dart';
import 'doctor_page.dart';

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
        "color": const Color.fromARGB(255, 131, 101, 108),
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
        "color": const Color.fromARGB(255, 0, 193, 241),
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
        title: const Text("All Categories"),
        backgroundColor: Colors.teal,
        elevation: 4,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: GridView.builder(
          itemCount: allCategories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final item = allCategories[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorsPage(
                      categoryName: item["name"],
                      doctors: doctors,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: item["color"],
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: (item["color"] as Color).withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(2, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white24,
                      ),
                      child: Icon(item["icon"], color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item["name"],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
