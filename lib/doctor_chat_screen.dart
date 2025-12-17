import 'package:flutter/material.dart';
import 'doctor_home_screen.dart';

class DoctorChatScreen extends StatelessWidget {
  const DoctorChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
            );
          },
        ),
        title: const Text(
          "Chats",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ChatTile(name: "Ahmed Ali", message: "Doctor, I need help with pain"),
          ChatTile(name: "Mohamed Samir", message: "When is my appointment?"),
          ChatTile(name: "Sara Hassan", message: "Thank you doctor ❤️"),
        ],
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final String name;
  final String message;

  const ChatTile({super.key, required this.name, required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          radius: 24,
          backgroundColor: Colors.teal,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(message),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}
