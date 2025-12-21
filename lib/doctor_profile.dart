import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shifa/Services/firebase_services.dart';
import 'package:shifa/welcome.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});
  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  final FirebaseServices _firebaseServices = FirebaseServices();
  final supabase = Supabase.instance.client;

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
  bool isUploadingImage = false;
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
  String? profileImageUrl;
  final ImagePicker _picker = ImagePicker();

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
          profileImageUrl = profile['imageUrl'];

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

  // ================= DELETE IMAGE =================
  Future<void> deleteProfileImage() async {
    try {
      if (doctorId == null) throw Exception('User not authenticated');

      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Profile Picture?'),
          content: const Text('Are you sure you want to remove your profile picture?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      setState(() => isUploadingImage = true);

      // Find all files in doctor's folder
      final files = await supabase.storage
          .from('doctor-images')
          .list(path: doctorId!);

      // Delete all profile images (in case of different extensions)
      for (var file in files) {
        if (file.name.startsWith('profile.')) {
          await supabase.storage
              .from('doctor-images')
              .remove(['$doctorId/${file.name}']);
        }
      }

      // Remove from Firestore
      await _firebaseServices.updateDoctorProfile(doctorId!, {
        'imageUrl': null,
      });

      setState(() {
        profileImageUrl = null;
        isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile picture removed'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() => isUploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Delete failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ================= PICK & UPLOAD IMAGE =================
  Future<void> pickProfileImage() async {
    try {
      // STEP 1: User picks image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      setState(() => isUploadingImage = true);

      // ✅ Security Check
      if (doctorId == null) {
        throw Exception('⚠️ You must be logged in to upload images');
      }

      // STEP 2: Flutter reads image as bytes
      final Uint8List bytes = await image.readAsBytes();
      final ext = image.name.split('.').last.toLowerCase();
      
      // ✅ Validate file extension
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
        throw Exception('Invalid image format. Use JPG, PNG, or WebP');
      }

      // ✅ Validate file size (max 5MB)
      if (bytes.length > 5 * 1024 * 1024) {
        throw Exception('Image too large. Max size is 5MB');
      }

      // ✅ STEP 2.5: Delete old profile images before uploading new one
      try {
        final files = await supabase.storage
            .from('doctor-images')
            .list(path: doctorId!);

        // Delete all old profile images (any extension)
        final filesToDelete = files
            .where((file) => file.name.startsWith('profile.'))
            .map((file) => '$doctorId/${file.name}')
            .toList();

        if (filesToDelete.isNotEmpty) {
          await supabase.storage
              .from('doctor-images')
              .remove(filesToDelete);
        }
      } catch (e) {
        debugPrint('No old images to delete: $e');
      }

      // Create file path: {doctorId}/profile.{ext}
      final filePath = '$doctorId/profile.$ext';

      // STEP 3: Upload to Supabase Storage (bucket: doctor-images)
      await supabase.storage.from('doctor-images').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/$ext',
            ),
          );

      // STEP 4: Get public URL
      final publicUrl =
          supabase.storage.from('doctor-images').getPublicUrl(filePath);

      // Add cache-busting timestamp
      final finalUrl = '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';

      // STEP 5: Save URL to Firebase Firestore
      await _firebaseServices.updateDoctorProfile(doctorId!, {
        'imageUrl': finalUrl,
      });

      // STEP 6: Display image in UI
      setState(() {
        profileImageUrl = finalUrl;
        isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile image updated successfully!'),
            backgroundColor: Colors.teal,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => isUploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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
            // Profile Image with Delete Button
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: isUploadingImage ? null : pickProfileImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white24,
                        backgroundImage: profileImageUrl != null
                            ? NetworkImage(profileImageUrl!)
                            : null,
                        child: profileImageUrl == null
                            ? const Icon(Icons.camera_alt,
                                color: Colors.white, size: 30)
                            : null,
                      ),
                      if (isUploadingImage)
                        const Positioned.fill(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Delete button (only show when image exists)
                if (profileImageUrl != null && !isUploadingImage)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: deleteProfileImage,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.delete_forever,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
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