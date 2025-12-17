import 'package:flutter/material.dart';
// import 'package:nav1/categories_card.dart';
import 'Details.dart';

class Doctor {
  final String name;
  final String specialty;
  final double rating;
  final int yearsExp;
  final String location;
  final double distance;
  final double price;

  Doctor({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.yearsExp,
    required this.location,
    required this.distance,
    required this.price,
  });
}

// --------------------------------------------
// ✔️ دكاترة – بعد تصحيح التخصصات
// --------------------------------------------
final List<Doctor> doctors = [
  Doctor(
    name: 'Dr. Amira Ali',
    specialty: 'Cardiology',
    rating: 4.9,
    yearsExp: 12,
    location: 'City Hospital',
    distance: 2.5,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Shorouk Abdelaleem',
    specialty: 'Cardiology',
    rating: 4.9,
    yearsExp: 12,
    location: 'City Hospital',
    distance: 2.5,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Wafaa Hamada',
    specialty: 'Cardiology',
    rating: 4.9,
    yearsExp: 12,
    location: 'City Hospital',
    distance: 2.5,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Doha Ahmed',
    specialty: 'Cardiology',
    rating: 4.9,
    yearsExp: 12,
    location: 'City Hospital',
    distance: 2.5,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Zeyad Hassanien',
    specialty: 'Cardiology',
    rating: 4.9,
    yearsExp: 12,
    location: 'City Hospital',
    distance: 2.5,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Sarah Johnson',
    specialty: 'Cardiology',
    rating: 4.9,
    yearsExp: 12,
    location: 'City Hospital',
    distance: 2.5,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Natalie Cooper',
    specialty: 'Cardiology',
    rating: 4.9,
    yearsExp: 12,
    location: 'City Hospital',
    distance: 2.5,
    price: 200,
  ),

  // Dermatology
  Doctor(
    name: 'Dr. William Archer',
    specialty: 'Dermatology',
    rating: 4.9,
    yearsExp: 12,
    location: 'City Hospital',
    distance: 2.5,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Harper Lawson',
    specialty: 'Dermatology',
    rating: 4.8,
    yearsExp: 15,
    location: 'Memorial Clinic',
    distance: 1.8,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Benjamin Cole',
    specialty: 'Dermatology',
    rating: 4.7,
    yearsExp: 8,
    location: 'Health Center',
    distance: 3.1,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Grace Mitchell',
    specialty: 'Dermatology',
    rating: 4.7,
    yearsExp: 8,
    location: 'Health Center',
    distance: 3.1,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Samuel Foster',
    specialty: 'Dermatology',
    rating: 4.7,
    yearsExp: 8,
    location: 'Health Center',
    distance: 3.1,
    price: 200,
  ),

  // Neurology
  Doctor(
    name: 'Dr. Lily Anderson',
    specialty: 'Neurology',
    rating: 4.7,
    yearsExp: 8,
    location: 'Health Center',
    distance: 3.1,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Noah Patterson',
    specialty: 'Neurology',
    rating: 4.7,
    yearsExp: 8,
    location: 'Health Center',
    distance: 3.1,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Emma Collins',
    specialty: 'Neurology',
    rating: 4.7,
    yearsExp: 8,
    location: 'Health Center',
    distance: 3.1,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Henry Phillips',
    specialty: 'Neurology',
    rating: 4.7,
    yearsExp: 8,
    location: 'Health Center',
    distance: 3.1,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Ava Thompson',
    specialty: 'Neurology',
    rating: 4.7,
    yearsExp: 8,
    location: 'Health Center',
    distance: 3.1,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Oliver Hayes',
    specialty: 'Neurology',
    rating: 4.7,
    yearsExp: 8,
    location: 'Health Center',
    distance: 3.1,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Hannah Morgan',
    specialty: 'Neurology',
    rating: 4.7,
    yearsExp: 8,
    location: 'Health Center',
    distance: 3.1,
    price: 200,
  ),

  // Pediatrics
  Doctor(
    name: 'Dr. Madeline Ross',
    specialty: 'Pediatrics',
    rating: 4.7,
    yearsExp: 8,
    location: 'Health Center',
    distance: 3.1,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Adrian Blake',
    specialty: 'Pediatrics',
    rating: 4.7,
    yearsExp: 8,
    location: 'Health Center',
    distance: 3.1,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Stella Hughes',
    specialty: 'Pediatrics',
    rating: 4.7,
    yearsExp: 8,
    location: 'Health Center',
    distance: 3.1,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Carter Reynolds',
    specialty: 'Pediatrics',
    rating: 4.7,
    yearsExp: 8,
    location: 'Health Center',
    distance: 3.1,
    price: 200,
  ),

  // Orthopedics
  Doctor(
    name: 'Dr. Isabella Monroe',
    specialty: 'Orthopedics',
    rating: 4.7,
    yearsExp: 8,
    location: 'Health Center',
    distance: 3.1,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Felix Grant',
    specialty: 'Orthopedics',
    rating: 4.7,
    yearsExp: 8,
    location: 'Health Center',
    distance: 3.1,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Zoe Parker',
    specialty: 'Orthopedics',
    rating: 4.7,
    yearsExp: 8,
    location: 'Health Center',
    distance: 3.1,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Miles Donovan',
    specialty: 'Orthopedics',
    rating: 4.7,
    yearsExp: 8,
    location: 'Health Center',
    distance: 3.1,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Evelyn Hart',
    specialty: 'Orthopedics',
    rating: 4.7,
    yearsExp: 8,
    location: 'Health Center',
    distance: 3.1,
    price: 200,
  ),
  Doctor(
    name: 'Dr. Julian Cross',
    specialty: 'Orthopedics',
    rating: 4.7,
    yearsExp: 8,
    location: 'Health Center',
    distance: 3.1,
    price: 200,
  ),
];

class DoctorsPage extends StatelessWidget {
  final String categoryName;
  final List<Doctor> doctors;

  const DoctorsPage({
    super.key,
    required this.categoryName,
    required this.doctors,
  });

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = doctors
        .where(
          (doc) =>
              doc.specialty.trim().toLowerCase() ==
              categoryName.trim().toLowerCase(),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "$categoryName Doctors",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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

      body: filteredDoctors.isEmpty
          ? const Center(
              child: Text(
                "No doctors found",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredDoctors.length,
              itemBuilder: (context, index) {
                final doctor = filteredDoctors[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorDetailsPage(doctor: doctor),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [Color(0xff39ab4a), Color(0xff009f93)],
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      leading: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 36,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      title: Text(
                        doctor.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            doctor.specialty,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.yellow.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                doctor.rating.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${doctor.distance} km",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DoctorDetailsPage(doctor: doctor),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                        ),
                        child: const Text("Book"),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
