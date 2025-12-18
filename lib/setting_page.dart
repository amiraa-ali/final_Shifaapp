import 'package:flutter/material.dart';
import 'package:shifa/Services/firebase_services.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final FirebaseServices _firebaseServices = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
      body: ListView(
        children: [
          const SizedBox(height: 20),

          // Account Section
          ListTile(
            leading: const Icon(Icons.person, color: Colors.teal),
            title: const Text("Account"),
            subtitle: const Text("Update your profile info"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to profile edit screen if needed
            },
          ),

          const Divider(),

          // Notifications
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.teal),
            title: const Text("Notifications"),
            subtitle: const Text("Manage notification settings"),
            trailing: Switch(
              value: true,
              onChanged: (val) {
                // Handle notification toggle
              },
            ),
          ),

          const Divider(),

          // Language
          ListTile(
            leading: const Icon(Icons.language, color: Colors.teal),
            title: const Text("Language"),
            subtitle: const Text("Change app language"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to language selection
            },
          ),

          const Divider(),

          // Privacy
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.teal),
            title: const Text("Privacy"),
            subtitle: const Text("Privacy settings"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to privacy settings
            },
          ),

          const Divider(),

          // About
          ListTile(
            leading: const Icon(Icons.info, color: Colors.teal),
            title: const Text("About"),
            subtitle: const Text("App version and info"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("About Shifa"),
                  content: const Text(
                    "Shifa Medical App\nVersion 1.0.0\n\nA comprehensive medical appointment and consultation platform.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(),

          // Help & Support
          ListTile(
            leading: const Icon(Icons.help, color: Colors.teal),
            title: const Text("Help & Support"),
            subtitle: const Text("Get help and contact support"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to help screen
            },
          ),

          const Divider(),

          const SizedBox(height: 20),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Show confirmation dialog
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text("Logout"),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true && context.mounted) {
                    // Show loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );

                    try {
                      await _firebaseServices.logout();

                      if (!context.mounted) return;

                      // Close loading dialog
                      Navigator.pop(context);

                      // Navigate to welcome screen
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/welcome', (route) => false);
                    } catch (e) {
                      if (!context.mounted) return;

                      // Close loading dialog
                      Navigator.pop(context);

                      // Show error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error logging out: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Sign Out",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Delete Account (Optional)
          Center(
            child: TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Account"),
                    content: const Text(
                      "Are you sure you want to delete your account? This action cannot be undone.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          // Handle account deletion
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Account deletion requested'),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                "Delete Account",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
