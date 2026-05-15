import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  bool appointmentReminders = true;
  bool emailNotifications = false;

  String selectedLanguage = 'English';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

      darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;

      appointmentReminders = prefs.getBool('appointment_reminders') ?? true;

      emailNotifications = prefs.getBool('email_notifications') ?? false;

      selectedLanguage = prefs.getString('selected_language') ?? 'English';

      isLoading = false;
    });
  }

  Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(key, value);
  }

  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xff009f93)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
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

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSectionTitle('General'),

            const SizedBox(height: 14),

            _buildCard(
              children: [
                _buildSwitchTile(
                  title: 'Notifications',
                  subtitle: 'Enable push notifications',
                  icon: Icons.notifications_active,
                  value: notificationsEnabled,
                  onChanged: (value) async {
                    setState(() {
                      notificationsEnabled = value;
                    });

                    await saveBool('notifications_enabled', value);
                  },
                ),

                const Divider(height: 0),

                _buildSwitchTile(
                  title: 'Appointment Reminders',
                  subtitle: 'Receive reminders before appointments',
                  icon: Icons.alarm,
                  value: appointmentReminders,
                  onChanged: (value) async {
                    setState(() {
                      appointmentReminders = value;
                    });

                    await saveBool('appointment_reminders', value);
                  },
                ),

                const Divider(height: 0),

                _buildSwitchTile(
                  title: 'Email Notifications',
                  subtitle: 'Receive updates via email',
                  icon: Icons.email_outlined,
                  value: emailNotifications,
                  onChanged: (value) async {
                    setState(() {
                      emailNotifications = value;
                    });

                    await saveBool('email_notifications', value);
                  },
                ),

                const Divider(height: 0),

                _buildSwitchTile(
                  title: 'Dark Mode',
                  subtitle: 'Enable dark appearance',
                  icon: Icons.dark_mode_outlined,
                  value: darkModeEnabled,
                  onChanged: (value) async {
                    setState(() {
                      darkModeEnabled = value;
                    });

                    await saveBool('dark_mode_enabled', value);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Language'),

            const SizedBox(height: 14),

            _buildCard(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),

                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.language, color: Colors.teal),
                  ),

                  title: const Text(
                    'App Language',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  subtitle: Text(selectedLanguage),

                  trailing: DropdownButton<String>(
                    value: selectedLanguage,
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(16),
                    items: const [
                      DropdownMenuItem(
                        value: 'English',
                        child: Text('English'),
                      ),
                      DropdownMenuItem(value: 'Arabic', child: Text('Arabic')),
                    ],
                    onChanged: (value) async {
                      if (value == null) return;

                      setState(() {
                        selectedLanguage = value;
                      });

                      await saveString('selected_language', value);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('About'),

            const SizedBox(height: 14),

            _buildCard(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),

                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline, color: Colors.teal),
                  ),

                  title: const Text(
                    'About Shifa',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  subtitle: const Text('Version 1.0.0'),

                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          title: const Text('About Shifa'),
                          content: const Text(
                            'Shifa Medical App\n\n'
                            'Version 1.0.0\n\n'
                            'A complete healthcare platform '
                            'for booking doctors, managing appointments, '
                            'and improving patient care experience.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'OK',
                                style: TextStyle(color: Colors.teal),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                const Divider(height: 0),

                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),

                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.help_outline, color: Colors.teal),
                  ),

                  title: const Text(
                    'Help & Support',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  subtitle: const Text('Contact support team'),

                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),

      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.teal.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.teal),
      ),

      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

      subtitle: Text(subtitle),

      value: value,

      activeColor: Colors.teal,

      onChanged: onChanged,
    );
  }
}
