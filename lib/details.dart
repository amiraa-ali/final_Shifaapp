import 'package:flutter/material.dart';
import 'Booking.dart';

class DoctorDetailsPage extends StatelessWidget {
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String location;
  final double price;

  const DoctorDetailsPage({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.location,
    required this.price,
  });

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
            doctorName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xff009f93),
            ),
          ),
          const SizedBox(height: 5),
          Text(specialty, style: const TextStyle(color: Colors.grey)),

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
                  "${price.toStringAsFixed(0)} EGP",
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
                          "$doctorName is a top specialist in $specialty. "
                          "They have achieved several awards for wonderful contribution "
                          "in the medical field and is available for private consultation.",
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
                        doctorId: doctorId,
                        doctorName: doctorName,
                        doctorSpecialty: specialty,
                        clinicLocation: location,
                        serviceType: specialty,
                        totalAmount: price.toStringAsFixed(0),
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
