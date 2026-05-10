import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shifa/Services/firebase_services.dart';
import 'package:shifa/setting_page.dart';
import 'package:shifa/welcome.dart';
import 'package:shifa/app_theme.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  final FirebaseServices _firebaseServices = FirebaseServices();

  final supabase = Supabase.instance.client;

  final _formKey = GlobalKey<FormState>();

  bool isLoading = true;

  bool isSaving = false;

  bool isUploadingImage = false;

  String? doctorId;

  final emailController = TextEditingController();

  final phoneController = TextEditingController();

  final locationController = TextEditingController();

  final specializationController = TextEditingController();

  final universityController = TextEditingController();

  final certificateController = TextEditingController();

  final aboutController = TextEditingController();

  final feesController = TextEditingController();

  String nameDisplay = 'Doctor';

  String? profileImageUrl;

  final ImagePicker _picker = ImagePicker();

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

  Future<void> _loadDoctorProfile() async {
    try {
      setState(() {
        isLoading = true;
      });

      doctorId = _firebaseServices.getCurrentUserId();

      if (doctorId == null) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      final profile = await _firebaseServices.getDoctorProfile(doctorId!);

      if (!mounted) return;

      if (profile != null) {
        setState(() {
          nameDisplay = profile['name'] ?? 'Doctor';

          emailController.text = profile['email'] ?? '';

          phoneController.text = profile['phone'] ?? '';

          locationController.text = profile['clinicLocation'] ?? '';

          specializationController.text = profile['specialization'] ?? '';

          universityController.text = profile['university'] ?? '';

          certificateController.text = profile['certificate'] ?? '';

          aboutController.text = profile['about'] ?? '';

          feesController.text = (profile['fees'] ?? 0).toString();

          profileImageUrl = profile['imageUrl'];

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image == null) return;

      setState(() {
        isUploadingImage = true;
      });

      final Uint8List bytes = await image.readAsBytes();

      final ext = image.name.split('.').last;

      final path = '$doctorId/profile.$ext';

      await supabase.storage
          .from('doctor-images')
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: 'image/$ext'),
          );

      final publicUrl = supabase.storage
          .from('doctor-images')
          .getPublicUrl(path);

      final imageUrl = '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';

      await _firebaseServices.updateDoctorProfile(doctorId!, {
        'imageUrl': imageUrl,
      });

      if (!mounted) return;

      setState(() {
        profileImageUrl = imageUrl;

        isUploadingImage = false;
      });

      _showSnackBar('Profile image updated successfully');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isUploadingImage = false;
      });

      _showSnackBar(e.toString(), isError: true);
    }
  }

  Future<void> saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (doctorId == null) return;

    try {
      setState(() {
        isSaving = true;
      });

      await _firebaseServices.updateDoctorProfile(doctorId!, {
        'phone': phoneController.text.trim(),
        'clinicLocation': locationController.text.trim(),
        'specialization': specializationController.text.trim(),
        'university': universityController.text.trim(),
        'certificate': certificateController.text.trim(),
        'about': aboutController.text.trim(),
        'fees': double.tryParse(feesController.text) ?? 0,
      });

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

  Future<void> _logout() async {
    await _firebaseServices.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
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

      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton.extended(
          onPressed: isSaving ? null : saveForm,

          backgroundColor: AppColors.primary,

          elevation: 5,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          icon: const Icon(Icons.save, color: Colors.white),

          label: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              "Save Changes",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
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

                const SizedBox(height: 18),

                _buildStatusCard(),

                const SizedBox(height: 18),

                _buildProfessionalSection(),

                const SizedBox(height: 18),

                _buildContactSection(),

                const SizedBox(height: 18),

                _buildEducationSection(),

                const SizedBox(height: 18),

                _buildAboutSection(),

                const SizedBox(height: 18),

                _buildSettingsSection(),

                const SizedBox(height: 140),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                width: 155,
                height: 155,
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
                onTap: pickProfileImage,
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
            nameDisplay,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
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

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Verified Doctor',
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
    );
  }

  Widget _buildStatusCard() {
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xff00A99D), Color(0xff18C08F)],
              ),
            ),
            child: const Icon(
              Icons.medical_services,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Professional Doctor",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  "Keep your profile updated.",
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalSection() {
    return buildCard(
      title: 'Professional Information',
      icon: Icons.medical_services,
      children: [
        buildField(
          controller: specializationController,
          label: 'Specialization',
          icon: Icons.local_hospital,
        ),
        buildField(
          controller: feesController,
          label: 'Consultation Fees',
          icon: Icons.attach_money,
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return buildCard(
      title: 'Contact Information',
      icon: Icons.contact_phone,
      children: [
        buildField(
          controller: emailController,
          label: 'Email',
          icon: Icons.email,
          enabled: false,
        ),
        buildField(
          controller: phoneController,
          label: 'Phone',
          icon: Icons.phone,
        ),
        buildField(
          controller: locationController,
          label: 'Clinic Location',
          icon: Icons.location_on,
        ),
      ],
    );
  }

  Widget _buildEducationSection() {
    return buildCard(
      title: 'Education',
      icon: Icons.school,
      children: [
        buildField(
          controller: universityController,
          label: 'University',
          icon: Icons.school,
        ),
        buildField(
          controller: certificateController,
          label: 'Certificate',
          icon: Icons.workspace_premium,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xffE8F7F5),
                    child: Icon(Icons.info, color: AppColors.primary),
                  ),
                  SizedBox(width: 14),
                  Text(
                    "About Doctor",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: aboutController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Write about the doctor...',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Column(
          children: [
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xffE8F7F5),
                child: Icon(Icons.settings, color: AppColors.primary),
              ),
              title: const Text('Settings'),
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
              leading: CircleAvatar(
                backgroundColor: Colors.red.withOpacity(0.1),
                child: const Icon(Icons.logout, color: Colors.red),
              ),
              title: const Text('Logout'),
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
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xffE8F7F5),
                    child: Icon(icon, color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

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
