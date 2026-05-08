import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shifa/Services/firebase_services.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  final FirebaseServices _firebaseServices = FirebaseServices();
  final supabase = Supabase.instance.client;

  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  bool isSaving = false;
  bool isUploadingImage = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final dobController = TextEditingController();

  String? profileImageUrl;
  final ImagePicker _picker = ImagePicker();

  final Map<String, bool> medicalSelected = {
    'Hypertension': false,
    'Type 2 Diabetes': false,
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
    nameController.addListener(() => setState(() {}));
  }

  // ================= LOAD USER DATA =================
  Future<void> _loadUserData() async {
    try {
      final userData = await _firebaseServices.getUserData();
      final authUser = FirebaseAuth.instance.currentUser;

      setState(() {
        nameController.text = userData?['name'] ?? '';
        phoneController.text = userData?['phone'] ?? '';
        locationController.text = userData?['location'] ?? '';
        dobController.text = userData?['dateOfBirth'] ?? '';
        profileImageUrl = userData?['imageUrl'];
        emailController.text = authUser?.email ?? '';

        if (userData?['medicalConditions'] != null) {
          medicalSelected
            ..clear()
            ..addAll(Map<String, bool>.from(userData!['medicalConditions']));
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  // ================= DELETE IMAGE =================
  Future<void> deleteProfileImage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Profile Picture?'),
          content: const Text(
            'Are you sure you want to remove your profile picture?',
          ),
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

      // Find all files in user's folder
      final files = await supabase.storage
          .from('patient-images')
          .list(path: user.uid);

      // Delete all profile images (in case of different extensions)
      for (var file in files) {
        if (file.name.startsWith('profile.')) {
          await supabase.storage.from('patient-images').remove([
            '${user.uid}/${file.name}',
          ]);
        }
      }

      // Remove from Firebase Auth
      await user.updatePhotoURL(null);

      // Remove from Firestore
      await _firebaseServices.updatePatientProfile(user.uid, {
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

      // ✅ Security Check: Verify Firebase user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('⚠️ You must be logged in to upload images');
      }

      // STEP 2: Flutter reads image as bytes
      final Uint8List bytes = await image.readAsBytes();
      final ext = image.name.split('.').last.toLowerCase();

      // ✅ Validate file extension (security)
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
            .from('patient-images')
            .list(path: user.uid);

        // Delete all old profile images (any extension)
        final filesToDelete = files
            .where((file) => file.name.startsWith('profile.'))
            .map((file) => '${user.uid}/${file.name}')
            .toList();

        if (filesToDelete.isNotEmpty) {
          await supabase.storage.from('patient-images').remove(filesToDelete);
        }
      } catch (e) {
        // Ignore errors if folder doesn't exist yet
        debugPrint('No old images to delete: $e');
      }

      // Create file path: {userId}/profile.{ext}
      // ✅ Using Firebase UID ensures each user has their own folder
      final filePath = '${user.uid}/profile.$ext';

      // STEP 3: Upload to Supabase Storage (bucket: patient-images)
      // Note: Policies are set to 'true' because we're using Firebase Auth
      await supabase.storage
          .from('patient-images')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              upsert: true, // Replace if exists
              contentType: 'image/$ext',
            ),
          );

      // STEP 4: Get public URL
      final publicUrl = supabase.storage
          .from('patient-images')
          .getPublicUrl(filePath);

      // Add cache-busting timestamp to force image refresh
      final finalUrl = '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';

      // Update Firebase Auth photoURL (helps with consistency)
      await user.updatePhotoURL(finalUrl);

      // STEP 5: Save URL to Firebase Firestore
      await _firebaseServices.updatePatientProfile(user.uid, {
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

  // ================= SAVE PROFILE DATA =================
  Future<void> saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final userId = _firebaseServices.getCurrentUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      await _firebaseServices.updatePatientProfile(userId, {
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'location': locationController.text.trim(),
        'dateOfBirth': dobController.text.trim(),
        'medicalConditions': medicalSelected,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profile updated successfully'),
          backgroundColor: Colors.teal,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => isSaving = false);
    }
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
        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE2E0E0),
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
                'Done',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ================= HEADER =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff39ab4a), Color(0xff009f93)],
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                  ),
                ),
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
  child: profileImageUrl != null
      ? ClipOval(
          child: Image.network(
            profileImageUrl!,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Image error: $error');
              return const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              );
            },
          ),
        )
      : const Icon(
          Icons.camera_alt,
          color: Colors.white,
          size: 20,
        ),
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
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
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
                                    size: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      nameController.text.isEmpty
                          ? 'User'
                          : nameController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      emailController.text,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================= INFO CARD =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        infoField(Icons.person, 'Name', nameController),
                        const Divider(),
                        infoField(
                          Icons.email,
                          'Email',
                          emailController,
                          enabled: false,
                        ),
                        const Divider(),
                        infoField(Icons.phone, 'Phone', phoneController),
                        const Divider(),
                        infoField(
                          Icons.location_on,
                          'Location',
                          locationController,
                        ),
                        const Divider(),
                        infoField(
                          Icons.calendar_today,
                          'Date of Birth',
                          dobController,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= MEDICAL CONDITIONS =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Medical Conditions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...medicalSelected.entries.map((e) {
                          return CheckboxListTile(
                            value: e.value,
                            onChanged: (v) =>
                                setState(() => medicalSelected[e.key] = v!),
                            title: Text(e.key),
                            activeColor: Colors.teal,
                          );
                        }),
                      ],
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

  Widget infoField(
    IconData icon,
    String label,
    TextEditingController c, {
    bool enabled = true,
  }) {
    return TextFormField(
      controller: c,
      enabled: enabled,
      decoration: InputDecoration(
        prefixIcon: CircleAvatar(
          backgroundColor: Colors.teal[50],
          child: Icon(icon, color: Colors.teal),
        ),
        labelText: label,
        border: InputBorder.none,
      ),
      validator: enabled && label != 'Email'
          ? (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter $label';
              }
              return null;
            }
          : null,
    );
  }
}
