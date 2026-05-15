import 'package:flutter/material.dart';

import 'package:shifa/patient_home_screen.dart';
import 'package:shifa/patient_chat_details_screen.dart';

import 'package:shifa/Services/appointment_service.dart';

class PatientChatScreen extends StatefulWidget {
  const PatientChatScreen({super.key});

  @override
  State<PatientChatScreen> createState() => _PatientChatScreenState();
}

class _PatientChatScreenState extends State<PatientChatScreen> {
  final AppointmentService _appointmentService = AppointmentService();

  List<dynamic> chats = [];

  bool isLoading = true;

  String error = '';

  @override
  void initState() {
    super.initState();

    _loadChats();
  }

  // =========================
  // LOAD CHATS
  // =========================
  Future<void> _loadChats() async {
    try {
      setState(() {
        isLoading = true;
      });

      final appointments = await _appointmentService.getPatientAppointments();

      // فقط المواعيد المسموح لها بالشات
      final allowedChats = appointments.where((item) {
        final status = item['status'] ?? '';

        return status == 'confirmed' ||
            status == 'completed' ||
            status == 'accepted' ||
            status == 'upcoming';
      }).toList();

      if (!mounted) return;

      setState(() {
        chats = allowedChats;

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();

        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),

          onPressed: () {
            Navigator.pushReplacement(
              context,

              MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
            );
          },
        ),

        title: const Text(
          "Doctor Chats",

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),

            onPressed: _loadChats,
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : error.isNotEmpty
          ? _buildError()
          : chats.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              onRefresh: _loadChats,

              child: ListView.builder(
                padding: const EdgeInsets.all(16),

                itemCount: chats.length,

                itemBuilder: (context, index) {
                  final chat = chats[index];

                  return ChatTile(
                    doctorName: chat['doctorName'] ?? 'Doctor',

                    doctorId: chat['doctorId'] ?? '',

                    specialty: chat['specialization'] ?? 'General',

                    lastMessage:
                        chat['lastMessage'] ??
                        'Start chatting with your doctor',

                    lastMessageTime:
                        DateTime.tryParse(chat['updatedAt'] ?? '') ??
                        DateTime.now(),

                    unreadCount: chat['unreadCount'] ?? 0,

                    imageUrl: chat['doctorImage'],

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => PatientChatDetailScreen(
                            chatId: chat['_id'] ?? '',

                            doctorName: chat['doctorName'] ?? 'Doctor',

                            doctorId: chat['doctorId'] ?? '',

                            specialty: chat['specialization'] ?? 'General',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }

  // =========================
  // EMPTY
  // =========================
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),

          const SizedBox(height: 16),

          Text(
            'No chats available',

            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),

          const SizedBox(height: 8),

          Text(
            'Book an appointment to start chatting',

            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // =========================
  // ERROR
  // =========================
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.error_outline, size: 70, color: Colors.red),

            const SizedBox(height: 16),

            Text(
              error,

              textAlign: TextAlign.center,

              style: const TextStyle(color: Colors.red),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _loadChats,

              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),

              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== CHAT TILE ====================

class ChatTile extends StatelessWidget {
  final String doctorName;

  final String doctorId;

  final String specialty;

  final String lastMessage;

  final DateTime lastMessageTime;

  final int unreadCount;

  final String? imageUrl;

  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.doctorName,
    required this.doctorId,
    required this.specialty,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.onTap,
    this.imageUrl,
  });

  String _getTimeAgo() {
    final now = DateTime.now();

    final difference = now.difference(lastMessageTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

      elevation: 3,

      shadowColor: Colors.black12,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(15),

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Row(
            children: [
              // AVATAR
              CircleAvatar(
                radius: 28,

                backgroundColor: Colors.teal.withOpacity(0.1),

                backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                    ? NetworkImage(imageUrl!)
                    : null,

                child: imageUrl == null || imageUrl!.isEmpty
                    ? Text(
                        doctorName[0].toUpperCase(),

                        style: const TextStyle(
                          color: Colors.teal,

                          fontWeight: FontWeight.bold,

                          fontSize: 22,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              // CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Expanded(
                          child: Text(
                            doctorName,

                            style: const TextStyle(
                              fontWeight: FontWeight.bold,

                              fontSize: 16,
                            ),

                            maxLines: 1,

                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        Text(
                          _getTimeAgo(),

                          style: TextStyle(
                            fontSize: 12,

                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    Text(
                      specialty,

                      style: TextStyle(
                        fontSize: 12,

                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage,

                            style: TextStyle(
                              color: unreadCount > 0
                                  ? Colors.black87
                                  : Colors.grey.shade700,

                              fontWeight: unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,

                              fontSize: 14,
                            ),

                            maxLines: 1,

                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        if (unreadCount > 0) ...[
                          const SizedBox(width: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,

                              vertical: 4,
                            ),

                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xff39ab4a), Color(0xff009f93)],
                              ),

                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: Text(
                              '$unreadCount',

                              style: const TextStyle(
                                color: Colors.white,

                                fontSize: 12,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
