import 'package:flutter/material.dart';
import 'booking.dart';
import 'doctor_page.dart';

class DoctorDetailsPage extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailsPage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    const gradientColorEnd = Color(0xff009f93);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Details",
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

      body: Column(
        children: [
          const SizedBox(height: 20),

          // ================= DOCTOR NAME =================
          Text(
            doctor.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xff009f93),
            ),
          ),
          const SizedBox(height: 5),
          Text(doctor.specialty, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 20),

          // ================= PRICE CARD =================
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff39ab4a), Color(0xff009f93)],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Consultation Price",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  "${doctor.price} EGP",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ================= BODY =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // ========== ABOUT ME CARD ==========
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xfff8f7fb),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "About me",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${doctor.name} is the top most immunologists specialist. "
                          "He achieved several awards for wonderful contribution "
                          "in medical field and is available for private consultation.",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // ========== WORKING TIME CARD ==========
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 40),
                    decoration: BoxDecoration(
                      color: const Color(0xfff8f7fb),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Working Time",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Monday - Friday, 08:00 AM - 20:00 PM",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= BOOK BUTTON =================
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: gradientColorEnd,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookAppointmentPage(
                        doctorId: doctor.id,
                        doctorName: doctor.name, // Pass to booking page
                        doctorSpecialty:
                            doctor.specialty, // Pass to booking page
                        clinicLocation: doctor.location,
                        serviceType:
                            doctor.specialty, // Or another relevant field
                        totalAmount: doctor.price.toString(),
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Book an Appointment",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
