import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
