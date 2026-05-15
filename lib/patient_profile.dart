import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shifa/Services/auth_service.dart';
import 'package:shifa/setting_page.dart';
import 'package:shifa/welcome.dart';
import 'package:shifa/app_theme.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  final AuthService _authService = AuthService();

  final _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();

  bool isLoading = true;

  bool isSaving = false;

  bool isUploadingImage = false;

  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final phoneController = TextEditingController();

  final locationController = TextEditingController();

  final dobController = TextEditingController();

  String? profileImageUrl;

  final Map<String, bool> medicalSelected = {
    'Hypertension': true,
    'Type 2 Diabetes': false,
  };

  @override
  void initState() {
    super.initState();

    _loadUserData();

    nameController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // =========================
  // LOAD USER DATA
  // =========================
  Future<void> _loadUserData() async {
    try {
      final response = await _authService.getPatientProfile();

      final user = response["patient"];

      if (!mounted) return;

      setState(() {
        nameController.text = user["name"] ?? '';

        emailController.text = user["email"] ?? '';

        phoneController.text = user["phone"] ?? '';

        locationController.text = user["location"] ?? '';

        dobController.text = user["dateOfBirth"] ?? '';

        profileImageUrl = user["imageUrl"];

        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showSnackBar("Failed to load profile", isError: true);
    }
  }

  // =========================
  // PICK & UPLOAD IMAGE
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

      final imageUrl = await _authService.uploadPatientImage(File(image.path));

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
  // SAVE FORM
  // =========================
  Future<void> saveForm() async {
    setState(() {
      isSaving = true;
    });

    try {
      await _authService.updatePatientProfile(
        name: nameController.text.trim(),

        phone: phoneController.text.trim(),

        location: locationController.text.trim(),

        dateOfBirth: dobController.text.trim(),
      );

      if (!mounted) return;

      _showSnackBar('Profile updated successfully');
    } catch (e) {
      if (!mounted) return;

      _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
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

  @override
  void dispose() {
    nameController.dispose();

    emailController.dispose();

    phoneController.dispose();

    locationController.dispose();

    dobController.dispose();

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

                const SizedBox(height: 22),

                _buildProfileStatusCard(),

                const SizedBox(height: 22),

                _buildInfoCard(),

                const SizedBox(height: 22),

                _buildMedicalConditions(),

                const SizedBox(height: 22),

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),

                  shape: BoxShape.circle,
                ),

                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),

                  borderRadius: BorderRadius.circular(18),
                ),

                child: const Row(
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: 18),

                    SizedBox(width: 8),

                    Text(
                      "Edit Profile",

                      style: TextStyle(
                        color: Colors.white,

                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          Stack(
            alignment: Alignment.bottomRight,

            children: [
              Container(
                width: 145,
                height: 145,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  border: Border.all(color: Colors.white, width: 5),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),

                      blurRadius: 24,

                      offset: const Offset(0, 12),
                    ),
                  ],
                ),

                child: ClipOval(
                  child: profileImageUrl != null
                      ? Image.network(profileImageUrl!, fit: BoxFit.cover)
                      : _buildDefaultAvatar(),
                ),
              ),

              GestureDetector(
                onTap: isUploadingImage ? null : _pickAndUploadImage,

                child: Container(
                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    shape: BoxShape.circle,

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),

                        blurRadius: 10,
                      ),
                    ],
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
                      : const Icon(
                          Icons.camera_alt,
                          color: AppColors.primary,
                          size: 24,
                        ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            nameController.text.isEmpty ? "Patient" : nameController.text,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            emailController.text,

            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStatusCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: const Color(0xffDDF2EC)),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 16),
        ],
      ),

      child: const Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,

            child: Icon(Icons.check, color: Colors.white),
          ),

          SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  "Profile looks good!",

                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 6),

                Text(
                  "Keep your information updated.",

                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Card(
        elevation: 6,

        shadowColor: Colors.black.withOpacity(0.05),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              infoField(Icons.person, 'Name', nameController),

              infoField(Icons.email, 'Email', emailController, enabled: false),

              infoField(Icons.phone, 'Phone', phoneController),

              infoField(Icons.location_on, 'Location', locationController),

              infoField(Icons.calendar_today, 'Date of Birth', dobController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalConditions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                "Medical Conditions",

                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              Wrap(
                spacing: 10,
                runSpacing: 10,

                children: medicalSelected.entries.map((entry) {
                  return Chip(
                    label: Text(entry.key),

                    backgroundColor: entry.value
                        ? AppColors.primary.withOpacity(0.12)
                        : Colors.grey.shade200,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
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

              trailing: const Icon(Icons.arrow_forward_ios, size: 16),

              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),

            const Divider(height: 0),

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

  Widget infoField(
    IconData icon,
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffE6EAF0)),

        borderRadius: BorderRadius.circular(22),
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),

        leading: CircleAvatar(
          radius: 28,

          backgroundColor: const Color(0xffE8F7F5),

          child: Icon(icon, color: AppColors.primary),
        ),

        title: Text(
          label,

          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),

          child: Text(
            controller.text.isEmpty ? "Not Added" : controller.text,

            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),

        trailing: Icon(
          enabled ? Icons.edit_outlined : Icons.lock_outline,

          color: enabled ? AppColors.primary : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff4FC3F7), Color(0xff81C784)],
        ),
      ),

      child: const Icon(Icons.person, size: 60, color: Colors.white),
    );
  }
}
