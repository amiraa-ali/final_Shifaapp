import 'package:flutter/material.dart';

import 'package:shifa/Booking.dart';

class DoctorDetailsPage extends StatelessWidget {
  final String doctorId;

  final String doctorName;

  final String specialty;

  final String location;

  final double price;

  final String? imageUrl;

  final String? about;

  final String? university;

  final String? certificate;

  final double? rating;

  final int? yearsExperience;

  const DoctorDetailsPage({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.location,
    required this.price,
    this.imageUrl,
    this.about,
    this.university,
    this.certificate,
    this.rating,
    this.yearsExperience,
  });

  @override
  Widget build(BuildContext context) {
    const gradientColorEnd = Color(0xff009f93);

    return Scaffold(
      backgroundColor: const Color(0xffF7F9FC),

      appBar: AppBar(
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Doctor Details",

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

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // =====================
            // DOCTOR IMAGE
            // =====================
            CircleAvatar(
              radius: 55,

              backgroundColor: Colors.grey.shade200,

              backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                  ? NetworkImage(imageUrl!)
                  : null,

              child: imageUrl == null || imageUrl!.isEmpty
                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                  : null,
            ),

            const SizedBox(height: 16),

            // =====================
            // NAME
            // =====================
            Text(
              doctorName,

              style: const TextStyle(
                fontSize: 24,

                fontWeight: FontWeight.bold,

                color: Color(0xff009f93),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              specialty,

              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),

            const SizedBox(height: 20),

            // =====================
            // STATS
            // =====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.star,
                      value: "${rating ?? 4.5}",
                      title: "Rating",
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.work_history,
                      value: "${yearsExperience ?? 1}+",

                      title: "Experience",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =====================
            // PRICE
            // =====================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff39ab4a), Color(0xff009f93)],

                  begin: Alignment.bottomRight,

                  end: Alignment.topLeft,
                ),

                borderRadius: BorderRadius.circular(18),
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

                      fontSize: 22,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =====================
            // DETAILS
            // =====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Column(
                children: [
                  _buildInfoCard(
                    title: "About Doctor",

                    content:
                        about ??
                        "$doctorName is a professional $specialty doctor with excellent experience in patient care and medical consultations.",
                  ),

                  _buildInfoCard(title: "Clinic Location", content: location),

                  _buildInfoCard(
                    title: "University",

                    content: university ?? "Medical University",
                  ),

                  _buildInfoCard(
                    title: "Certificate",

                    content: certificate ?? "Certified Specialist",
                  ),

                  _buildInfoCard(
                    title: "Working Time",

                    content: "Monday - Friday\n08:00 AM - 08:00 PM",
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),

      // =====================
      // BOOK BUTTON
      // =====================
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),

        child: SizedBox(
          width: double.infinity,

          height: 58,

          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: gradientColorEnd,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
              "Book Appointment",

              style: TextStyle(
                fontSize: 17,

                fontWeight: FontWeight.bold,

                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // STAT CARD
  // =========================
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),

      child: Column(
        children: [
          Icon(icon, color: const Color(0xff009f93)),

          const SizedBox(height: 10),

          Text(
            value,

            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          const SizedBox(height: 4),

          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // =========================
  // INFO CARD
  // =========================
  Widget _buildInfoCard({required String title, required String content}) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 10),

          Text(content, style: TextStyle(color: Colors.grey[700], height: 1.5)),
        ],
      ),
    );
  }
}
