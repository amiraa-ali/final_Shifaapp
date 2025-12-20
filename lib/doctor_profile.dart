import 'package:flutter/material.dart';
import 'package:shifa/Services/firebase_services.dart';
import 'package:shifa/welcome.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});
  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  final FirebaseServices _firebaseServices = FirebaseServices();

  static const Color primaryIconColor = Color(0xff009f93);
  static const Color lightIconBackground = Color(0xFFE0F7F7);
  static const LinearGradient unifiedGradient = LinearGradient(
    colors: [Color(0xff39ab4a), Color(0xff009f93)],
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
  );

  Color avatarColor = Colors.blue;
  final _formKey = GlobalKey<FormState>();

  // State management
  bool isLoading = true;
  bool isSaving = false;
  String? doctorId;

  // Controllers
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final specializationController = TextEditingController();
  final universityController = TextEditingController();
  final certificateController = TextEditingController();
  final aboutController = TextEditingController();
  final feesController = TextEditingController();

  String nameDisplay = 'Dr. Loading...';

  @override
  void initState() {
    super.initState();
    _loadDoctorProfile();

    specializationController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadDoctorProfile() async {
    setState(() => isLoading = true);

    doctorId = _firebaseServices.getCurrentUserId();

    if (doctorId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final profile = await _firebaseServices.getDoctorProfile(doctorId!);

      if (profile != null) {
        setState(() {
          nameDisplay = profile['name'] ?? 'Dr. Unknown';
          emailController.text = profile['email'] ?? '';
          phoneController.text = profile['phone'] ?? '';
          locationController.text = profile['clinicLocation'] ?? '';
          specializationController.text = profile['specialization'] ?? '';
          feesController.text = (profile['fees'] ?? 0).toString();

          // Load additional fields if they exist
          universityController.text = profile['university'] ?? '';
          certificateController.text = profile['certificate'] ?? '';
          aboutController.text = profile['about'] ?? '';

          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    specializationController.dispose();
    universityController.dispose();
    certificateController.dispose();
    aboutController.dispose();
    feesController.dispose();
    super.dispose();
  }

  void changeAvatar() => setState(
    () => avatarColor = avatarColor == Colors.blue ? Colors.red : Colors.blue,
  );

  Future<void> saveForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fix errors ⚠️')));
      return;
    }

    if (doctorId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error: Not logged in')));
      return;
    }

    setState(() => isSaving = true);

    try {
      // Prepare update data
      Map<String, dynamic> updateData = {
        'phone': phoneController.text.trim(),
        'clinicLocation': locationController.text.trim(),
        'specialization': specializationController.text.trim(),
        'university': universityController.text.trim(),
        'certificate': certificateController.text.trim(),
        'about': aboutController.text.trim(),
      };

      // Add fees if provided
      if (feesController.text.isNotEmpty) {
        updateData['fees'] = double.tryParse(feesController.text) ?? 0.0;
      }

      bool success = await _firebaseServices.updateDoctorProfile(
        doctorId!,
        updateData,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully! ✅'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firebaseServices.logout();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: primaryIconColor)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),

      floatingActionButton: isSaving
          ? const CircularProgressIndicator()
          : ElevatedButton(
              onPressed: saveForm,
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryIconColor,
                ),
              ),
            ),

      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ================= HEADER =================
              _buildProfileHeader(context),

              const SizedBox(height: 30),

              // ================= SPECIALIZATION =================
              sectionCard(
                title: "Specialization",
                children: [
                  _buildInfoField(
                    icon: Icons.medical_services,
                    label: "Specialization",
                    controller: specializationController,
                    validator: (v) => (v == null || v.isEmpty)
                        ? "Specialization required"
                        : null,
                    isLast: true,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ================= CONTACT INFORMATION =================
              sectionCard(
                title: "Contact Information",
                children: [
                  // Email (read-only)
                  _buildInfoField(
                    icon: Icons.email,
                    label: "Email (Cannot be changed)",
                    controller: emailController,
                    enabled: false,
                  ),
                  // Phone
                  _buildInfoField(
                    icon: Icons.phone,
                    label: "Phone",
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Phone is required";
                      if (v.length != 11 || int.tryParse(v) == null) {
                        return "Phone must be 11 digits";
                      }
                      return null;
                    },
                  ),
                  // Clinic / Location
                  _buildInfoField(
                    icon: Icons.location_on,
                    label: "Clinic / Location",
                    controller: locationController,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? "Clinic is required" : null,
                  ),
                  // Fees
                  _buildInfoField(
                    icon: Icons.attach_money,
                    label: "Consultation Fees (EGP)",
                    controller: feesController,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Fees required";
                      if (double.tryParse(v) == null) {
                        return "Enter valid number";
                      }
                      return null;
                    },
                    isLast: true,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ================= EDUCATION =================
              sectionCard(
                title: "Education",
                children: [
                  // University
                  _buildInfoField(
                    icon: Icons.account_balance,
                    label: "University",
                    controller: universityController,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? "University required" : null,
                  ),
                  // Certificate
                  _buildInfoField(
                    icon: Icons.workspace_premium,
                    label: "Certificate / Degree",
                    controller: certificateController,
                    validator: (v) => (v == null || v.isEmpty)
                        ? "Certificate required"
                        : null,
                    isLast: true,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ================= ABOUT =================
              sectionCard(
                title: "About Doctor",
                children: [
                  TextFormField(
                    controller: aboutController,
                    maxLines: 4,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? "About is required" : null,
                    decoration: InputDecoration(
                      hintText: "Write about the doctor...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 100),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _confirmLogout,
                    icon: const Icon(Icons.logout, color: Color.fromARGB(255, 255, 255, 255)),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Color.fromARGB(255, 249, 247, 247),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                     style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 40, bottom: 40, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: unifiedGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: SafeArea(
        top: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: changeAvatar,
              child: CircleAvatar(
                radius: 45,
                backgroundColor: avatarColor,
                child: const Icon(Icons.person, size: 40, color: Colors.white),
              ),
            ),

            const SizedBox(height: 15),
            Text(
              nameDisplay,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),
            Text(
              specializationController.text.isEmpty
                  ? "No Specialization"
                  : specializationController.text,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool isLast = false,
    bool enabled = true,
  }) {
    Widget inputField = TextFormField(
      controller: controller,
      maxLines: label.contains("About") ? 4 : 1,
      keyboardType: keyboardType,
      enabled: enabled,
      validator: (v) {
        WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
        return validator?.call(v);
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14,
          color: (validator?.call(controller.text) != null)
              ? Colors.red
              : enabled
              ? Colors.grey[700]
              : Colors.grey[500],
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
        errorText: validator?.call(controller.text),
        errorStyle: const TextStyle(fontSize: 13, color: Colors.red),
        errorMaxLines: 2,
      ),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: enabled ? Colors.black87 : Colors.grey,
      ),
    );

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: lightIconBackground,
                ),
                child: Icon(icon, color: primaryIconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: (validator?.call(controller.text) != null)
                            ? Colors.red
                            : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    inputField,
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget sectionCard({required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
