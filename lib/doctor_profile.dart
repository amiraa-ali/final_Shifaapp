import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shifa/Services/auth_service.dart';
import 'package:shifa/setting_page.dart';
import 'package:shifa/welcome.dart';
import 'package:shifa/app_theme.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  final AuthService _authService = AuthService();

  final _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();

  bool isLoading = true;

  bool isSaving = false;

  bool isUploadingImage = false;

  final emailController = TextEditingController();

  final phoneController = TextEditingController();

  final locationController = TextEditingController();

  final specializationController = TextEditingController();

  final universityController = TextEditingController();

  final certificateController = TextEditingController();

  final aboutController = TextEditingController();

  final feesController = TextEditingController();

  String doctorName = "Doctor";

  String? profileImageUrl;

  @override
  void initState() {
    super.initState();

    _loadDoctorProfile();

    specializationController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // =========================
  // LOAD PROFILE
  // =========================
  Future<void> _loadDoctorProfile() async {
    try {
      final response = await _authService.getDoctorProfile();

      final doctor = response["doctor"];

      if (!mounted) return;

      setState(() {
        doctorName = doctor["name"] ?? "Doctor";

        emailController.text = doctor["email"] ?? '';

        phoneController.text = doctor["phone"] ?? '';

        locationController.text = doctor["clinicLocation"] ?? '';

        specializationController.text = doctor["specialization"] ?? '';

        universityController.text = doctor["university"] ?? '';

        certificateController.text = doctor["certificate"] ?? '';

        aboutController.text = doctor["about"] ?? '';

        feesController.text = (doctor["fees"] ?? 0).toString();

        profileImageUrl = doctor["imageUrl"];

        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        isLoading = false;
      });

      _showSnackBar("Failed to load profile", isError: true);
    }
  }

  // =========================
  // UPLOAD IMAGE
  // =========================
  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      setState(() {
        isUploadingImage = true;
      });

      final imageUrl = await _authService.uploadDoctorImage(File(image.path));

      setState(() {
        profileImageUrl = imageUrl;
      });

      _showSnackBar("Image uploaded successfully");
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      setState(() {
        isUploadingImage = false;
      });
    }
  }

  // =========================
  // SAVE PROFILE
  // =========================
  Future<void> saveForm() async {
    try {
      setState(() {
        isSaving = true;
      });

      await _authService.updateDoctorProfile(
        phone: phoneController.text.trim(),

        location: locationController.text.trim(),

        specialization: specializationController.text.trim(),

        university: universityController.text.trim(),

        certificate: certificateController.text.trim(),

        about: aboutController.text.trim(),

        fees: feesController.text.trim(),
      );

      if (!mounted) return;

      _showSnackBar("Profile updated successfully");
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(builder: (_) => const WelcomeScreen()),

      (route) => false,
    );
  }

  // =========================
  // SNACKBAR
  // =========================
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,

        backgroundColor: isError ? Colors.red : AppColors.primary,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        content: Text(message),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FB),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: isSaving ? null : saveForm,

        backgroundColor: AppColors.primary,

        icon: isSaving
            ? const SizedBox(
                width: 20,
                height: 20,

                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save, color: Colors.white),

        label: const Text(
          "Save Changes",

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          child: Form(
            key: _formKey,

            child: Column(
              children: [
                _buildHeader(),

                const SizedBox(height: 20),

                _buildProfessionalCard(),

                const SizedBox(height: 20),

                _buildAboutCard(),

                const SizedBox(height: 20),

                _buildSettingsCard(),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // HEADER
  // =========================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(20, 40, 20, 36),

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff008E97), Color(0xff12B3A8), Color(0xff31C46C)],

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(42),

          bottomRight: Radius.circular(42),
        ),
      ),

      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,

            children: [
              CircleAvatar(
                radius: 70,

                backgroundColor: Colors.white,

                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
                    : null,

                child: profileImageUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.primary,
                      )
                    : null,
              ),

              GestureDetector(
                onTap: isUploadingImage ? null : _pickAndUploadImage,

                child: Container(
                  padding: const EdgeInsets.all(12),

                  decoration: const BoxDecoration(
                    color: Colors.white,

                    shape: BoxShape.circle,
                  ),

                  child: isUploadingImage
                      ? const SizedBox(
                          width: 20,
                          height: 20,

                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(Icons.camera_alt, color: AppColors.primary),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Text(
            doctorName,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            specializationController.text.isEmpty
                ? "Doctor"
                : specializationController.text,

            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCard() {
    return buildCard(
      title: "Professional Information",

      icon: Icons.medical_services,

      children: [
        buildField(
          controller: emailController,

          label: "Email",

          icon: Icons.email,

          enabled: false,
        ),

        buildField(
          controller: phoneController,

          label: "Phone",

          icon: Icons.phone,
        ),

        buildField(
          controller: locationController,

          label: "Clinic Location",

          icon: Icons.location_on,
        ),

        buildField(
          controller: specializationController,

          label: "Specialization",

          icon: Icons.local_hospital,
        ),

        buildField(
          controller: universityController,

          label: "University",

          icon: Icons.school,
        ),

        buildField(
          controller: certificateController,

          label: "Certificate",

          icon: Icons.workspace_premium,
        ),

        buildField(
          controller: feesController,

          label: "Consultation Fees",

          icon: Icons.attach_money,
        ),
      ],
    );
  }

  Widget _buildAboutCard() {
    return buildCard(
      title: "About Doctor",

      icon: Icons.info,

      children: [
        TextFormField(
          controller: aboutController,

          maxLines: 5,

          decoration: InputDecoration(
            hintText: "Write about yourself",

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),

        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.primary),

              title: const Text("Settings"),

              trailing: const Icon(Icons.arrow_forward_ios),

              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),

              title: const Text("Logout"),

              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xffE8F7F5),

                    child: Icon(icon, color: AppColors.primary),
                  ),

                  const SizedBox(width: 12),

                  Text(
                    title,

                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField({
    required TextEditingController controller,

    required String label,

    required IconData icon,

    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      child: TextFormField(
        controller: controller,

        enabled: enabled,

        decoration: InputDecoration(
          labelText: label,

          prefixIcon: Icon(icon),

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}
