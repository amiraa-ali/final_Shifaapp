import 'package:flutter/material.dart';

import 'package:shifa/Services/doctor_service.dart';
import 'package:shifa/doctor_card.dart';

class DoctorsPage extends StatefulWidget {
  final String? categoryName;

  const DoctorsPage({super.key, this.categoryName});

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  final DoctorService _doctorService = DoctorService();

  final TextEditingController _searchController = TextEditingController();

  List<dynamic> doctors = [];

  bool isLoading = true;

  String error = '';

  @override
  void initState() {
    super.initState();

    loadDoctors();
  }

  // =========================
  // LOAD DOCTORS
  // =========================
  Future<void> loadDoctors() async {
    try {
      setState(() {
        isLoading = true;
        error = '';
      });

      List<dynamic> result = [];

      // CATEGORY FILTER
      if (widget.categoryName != null && widget.categoryName!.isNotEmpty) {
        result = await _doctorService.getDoctorsBySpecialization(
          widget.categoryName!,
        );
      } else {
        result = await _doctorService.getDoctors();
      }

      if (!mounted) return;

      setState(() {
        doctors = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // =========================
  // SEARCH
  // =========================
  Future<void> searchDoctors(String query) async {
    try {
      setState(() {
        isLoading = true;
      });

      if (query.trim().isEmpty) {
        await loadDoctors();
        return;
      }

      final result = await _doctorService.searchDoctors(query);

      if (!mounted) return;

      setState(() {
        doctors = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

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
          // =====================
          // SEARCH BAR
          // =====================
          Padding(
            padding: const EdgeInsets.all(16),

            child: TextField(
              controller: _searchController,

              onChanged: searchDoctors,

              decoration: InputDecoration(
                hintText: 'Search doctors...',

                prefixIcon: const Icon(Icons.search, color: Color(0xff009f93)),

                filled: true,

                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),

                  borderSide: BorderSide.none,
                ),

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),

          // =====================
          // BODY
          // =====================
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xff009f93)),
                  )
                : error.isNotEmpty
                ? _buildErrorState()
                : doctors.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: loadDoctors,

                    child: ListView.builder(
                      itemCount: doctors.length,

                      padding: const EdgeInsets.only(bottom: 20),

                      itemBuilder: (context, index) {
                        final doctor = doctors[index];

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
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // =========================
  // EMPTY STATE
  // =========================
  Widget _buildEmptyState() {
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

            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),

          if (widget.categoryName != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),

              child: Text(
                'in ${widget.categoryName}',

                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ),
        ],
      ),
    );
  }

  // =========================
  // ERROR STATE
  // =========================
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.error_outline, size: 70, color: Colors.red),

            const SizedBox(height: 20),

            Text(
              error,

              textAlign: TextAlign.center,

              style: const TextStyle(color: Colors.red, fontSize: 15),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loadDoctors,

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff009f93),
              ),

              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
