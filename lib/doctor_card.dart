import 'package:flutter/material.dart';

/// ======================
/// DETAILS SCREEN (الصغيرة)
/// ======================
class DoctorDetailsScreen extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final double rating;
  final int yearsExp;
  final String location;
  final double distance;
  final String imagePath;
  final double price;

  const DoctorDetailsScreen({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.rating,
    required this.yearsExp,
    required this.location,
    required this.distance,
    required this.imagePath,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(doctorName)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doctorName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(specialty, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            Text(
              "Consultation Price: $price EGP",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ======================
/// DOCTOR CARD
/// ======================
class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final int yearsExp;
  final String location;
  final double distance;
  final String imagePath;
  final double price; // 👈 السعر

  const DoctorCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.yearsExp,
    required this.location,
    required this.distance,
    required this.imagePath,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ================= TOP SECTION =================
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorDetailsScreen(
                    doctorName: name,
                    specialty: specialty,
                    rating: rating,
                    yearsExp: yearsExp,
                    location: location,
                    distance: distance,
                    imagePath: imagePath,
                    price: price, // 👈 مهم
                  ),
                ),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    imagePath,
                    width: 80,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 100,
                      color: Colors.grey[200],
                      child: const Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 15),

                // INFO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        specialty,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text('$rating'),
                          const Text(' • '),
                          Text('$yearsExp years exp'),
                        ],
                      ),
                      const SizedBox(height: 5),

                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text('$location, ${distance.toStringAsFixed(1)} km'),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // 👇 السعر في الكارت
                      Text(
                        "$price EGP",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // ================= BOOK BUTTON =================
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2ECC71), Color(0xFF1ABC9C)],
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorDetailsScreen(
                        doctorName: name,
                        specialty: specialty,
                        rating: rating,
                        yearsExp: yearsExp,
                        location: location,
                        distance: distance,
                        imagePath: imagePath,
                        price: price, // 👈 مهم جدًا
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
