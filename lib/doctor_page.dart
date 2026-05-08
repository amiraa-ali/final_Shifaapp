import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shifa/Services/firebase_services.dart';
import 'package:shifa/doctor_card.dart';

class DoctorsPage extends StatefulWidget {
  final String? categoryName;

  const DoctorsPage({super.key, this.categoryName});

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  final FirebaseServices _firebaseServices = FirebaseServices();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getDoctorsStream() {
    if (widget.categoryName != null && widget.categoryName!.isNotEmpty) {
      return _firebaseServices.getDoctorsBySpecialty(widget.categoryName!);
    } else if (_searchQuery.isNotEmpty) {
      return _firebaseServices.searchDoctorsByName(_searchQuery);
    } else {
      return _firebaseServices.getAllDoctors();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName ?? 'All Doctors',
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
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search doctors...',
                prefixIcon: const Icon(Icons.search, color: Color(0xff009f93)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),

          // Doctors List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getDoctorsStream(),
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xff009f93)),
                  );
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }

                // No data state
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medical_services_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No doctors found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (widget.categoryName != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'in ${widget.categoryName}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                // Doctors list
                final doctors = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: doctors.length,
                  padding: const EdgeInsets.only(bottom: 20),
                  itemBuilder: (context, index) {
                    final doctorDoc = doctors[index];
                    final doctorData = doctorDoc.data() as Map<String, dynamic>;

                    // Extract doctor information with defaults
                    final doctorId = doctorDoc.id;
                    final name = doctorData['name'] ?? 'Doctor';
                    final specialty = doctorData['specialization'] ?? 'General';
                    final location = doctorData['clinicLocation'] ?? 'Clinic';
                    final rating = (doctorData['rating'] ?? 0.0).toDouble();
                    final yearsExp = (doctorData['yearsExperience'] ?? 0);
                    final price = (doctorData['fees'] ?? 0.0).toDouble();
                    final imageUrl = doctorData['imageUrl']; // ✅ من Firebase

                    final distance = 5.0; // Default distance

                    return DoctorCard(
                      doctorId: doctorId,
                      name: name,
                      specialty: specialty,
                      rating: rating,
                      yearsExp: yearsExp,
                      location: location,
                      distance: distance,
                      imageUrl: imageUrl, // ✅ غيّرتها من imagePath لـ imageUrl
                      price: price,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
