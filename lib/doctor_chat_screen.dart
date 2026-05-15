import 'package:flutter/material.dart';

import 'package:shifa/doctor_home_screen.dart';
import 'doctor_chat_detail_screen.dart';

import 'package:shifa/Services/appointment_service.dart';

class DoctorChatScreen extends StatefulWidget {
  const DoctorChatScreen({super.key});

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
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

      final appointments = await _appointmentService.getDoctorAppointments();

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
      backgroundColor: Colors.grey.shade50,

      appBar: AppBar(
        backgroundColor: Colors.teal,

        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),

          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,

              MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),

              (route) => false,
            );
          },
        ),

        title: const Text(
          "Patient Chats",

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                    chatId: chat['_id'] ?? '',

                    patientName: chat['patientName'] ?? 'Patient',

                    patientId: chat['patientId'] ?? '',

                    lastMessage: chat['lastMessage'] ?? 'Start conversation',

                    lastMessageTime:
                        DateTime.tryParse(chat['updatedAt'] ?? '') ??
                        DateTime.now(),

                    unreadCount: chat['unreadCount'] ?? 0,

                    patientAge: chat['patientAge'] ?? 0,

                    patientGender: chat['patientGender'] ?? 'Unknown',

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => DoctorChatDetailScreen(
                            chatId: chat['_id'] ?? '',

                            patientName: chat['patientName'] ?? 'Patient',

                            patientId: chat['patientId'] ?? '',

                            patientAge: chat['patientAge'] ?? 0,

                            patientGender: chat['patientGender'] ?? 'Unknown',
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
            'No patient chats',

            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),

          const SizedBox(height: 8),

          Text(
            'Chats will appear here after appointments',

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
  final String chatId;

  final String patientName;

  final String patientId;

  final String lastMessage;

  final DateTime lastMessageTime;

  final int unreadCount;

  final int patientAge;

  final String patientGender;

  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.chatId,
    required this.patientName,
    required this.patientId,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.patientAge,
    required this.patientGender,
    required this.onTap,
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

      elevation: 2,

      shadowColor: Colors.black12,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(16),

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Row(
            children: [
              // AVATAR
              Container(
                width: 56,
                height: 56,

                decoration: BoxDecoration(
                  color: Colors.teal.shade50,

                  shape: BoxShape.circle,
                ),

                child: Center(
                  child: Text(
                    patientName[0].toUpperCase(),

                    style: TextStyle(
                      fontSize: 24,

                      fontWeight: FontWeight.bold,

                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
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
                            patientName,

                            style: const TextStyle(
                              fontWeight: FontWeight.bold,

                              fontSize: 16,

                              color: Colors.black87,
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

                    const SizedBox(height: 4),

                    Text(
                      '$patientAge years • $patientGender',

                      style: TextStyle(
                        color: Colors.grey.shade600,

                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage,

                            style: TextStyle(
                              fontSize: 14,

                              color: unreadCount > 0
                                  ? Colors.black87
                                  : Colors.grey.shade600,

                              fontWeight: unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
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
                              color: Colors.teal,

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
