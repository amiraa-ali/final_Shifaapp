import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DoctorProfile(),
    );
  }
}

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});
  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  static const Color primaryIconColor = Color(0xff009f93);
  static const Color lightIconBackground = Color(0xFFE0F7F7);
  static const LinearGradient unifiedGradient = LinearGradient(
    colors: [Color(0xff39ab4a), Color(0xff009f93)],
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
  );

  Color avatarColor = Colors.blue;
  final _formKey = GlobalKey<FormState>();

  int _selectedIndex = 3;

  final emailController = TextEditingController(text: 'dr.sarah@gmail.com');
  final phoneController = TextEditingController(text: '01012345678');
  final locationController = TextEditingController(
    text: 'New Cairo Medical Center',
  );
  final specializationController = TextEditingController(
    text: "Dermatology & Ophthalmology",
  );
  final universityController = TextEditingController(text: "Cairo University");
  final certificateController = TextEditingController(
    text: "MD, Master Degree",
  );
  final aboutController = TextEditingController(
    text: "Experienced consultant with more than 10 years of practice ",
  );

  String nameDisplay = '';

  @override
  void initState() {
    super.initState();
    nameDisplay = 'Dr. Sarah';

    specializationController.addListener(() {
      setState(() {});
    });

    emailController.addListener(() {
      if (emailController.text.contains('@')) {
        setState(() => nameDisplay = emailController.text.split('@')[0]);
      }
    });
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
    super.dispose();
  }

  void changeAvatar() => setState(
    () => avatarColor = avatarColor == Colors.blue ? Colors.red : Colors.blue,
  );

  void onNavBarTapped(int index) => setState(() => _selectedIndex = index);

  void saveForm() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data is valid! ✅')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fix errors ⚠️')));
    }
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
  }) {
    String? validationMessage = validator != null
        ? validator(controller.text)
        : null;

    Widget inputField = TextFormField(
      controller: controller,
      maxLines: label.contains("About") ? 4 : 1,
      keyboardType: keyboardType,
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
              : Colors.grey[700],
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
        errorText: validator?.call(controller.text),
        errorStyle: const TextStyle(fontSize: 13, color: Colors.red),
        errorMaxLines: 2,
      ),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),

      floatingActionButton: ElevatedButton(
        onPressed: saveForm,
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        ),
        child: const Text(
          'Done',
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
                  // Email
                  _buildInfoField(
                    icon: Icons.email,
                    label: "Email",
                    controller: emailController,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Email is required";
                      if (!v.contains("@") || !v.contains(".")) {
                        return "Enter valid email";
                      }
                      return null;
                    },
                  ),
                  // Phone
                  _buildInfoField(
                    icon: Icons.phone,
                    label: "Phone",
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Phone is required";
                      if (v.length != 11 || int.tryParse(v ?? '') == null) {
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
            ],
          ),
        ),
      ),
    );
  }
}
