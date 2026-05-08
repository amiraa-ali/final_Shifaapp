import 'package:flutter/material.dart';
import 'package:shifa/doctor_home_screen.dart';
import 'doctor_chat_detail_screen.dart';

class DoctorChatScreen extends StatelessWidget {
  const DoctorChatScreen({super.key});

  // ==================== DUMMY CHATS DATA ====================
  static final List<Map<String, dynamic>> dummyChats = [
    {
      'chatId': 'chat_001',
      'patientName': 'Ahmed Hassan',
      'patientId': 'patient_001',
      'lastMessage': 'Thank you doctor! I feel much better now.',
      'lastMessageTime': DateTime.now().subtract(const Duration(minutes: 5)),
      'unreadCount': 0,
      'patientAge': 28,
      'patientGender': 'Male',
    },
    {
      'chatId': 'chat_002',
      'patientName': 'Sarah Mohamed',
      'patientId': 'patient_002',
      'lastMessage': 'When should I take the medication?',
      'lastMessageTime': DateTime.now().subtract(const Duration(hours: 2)),
      'unreadCount': 2,
      'patientAge': 35,
      'patientGender': 'Female',
    },
    {
      'chatId': 'chat_003',
      'patientName': 'Omar Ali',
      'patientId': 'patient_003',
      'lastMessage': 'Can I schedule a follow-up appointment?',
      'lastMessageTime': DateTime.now().subtract(const Duration(hours: 5)),
      'unreadCount': 1,
      'patientAge': 42,
      'patientGender': 'Male',
    },
    {
      'chatId': 'chat_004',
      'patientName': 'Fatma Ibrahim',
      'patientId': 'patient_004',
      'lastMessage': 'The test results have arrived.',
      'lastMessageTime': DateTime.now().subtract(const Duration(days: 1)),
      'unreadCount': 0,
      'patientAge': 31,
      'patientGender': 'Female',
    },
    {
      'chatId': 'chat_005',
      'patientName': 'Mahmoud Khaled',
      'patientId': 'patient_005',
      'lastMessage': 'I have some questions about the treatment.',
      'lastMessageTime': DateTime.now().subtract(const Duration(days: 2)),
      'unreadCount': 3,
      'patientAge': 45,
      'patientGender': 'Male',
    },
    {
      'chatId': 'chat_006',
      'patientName': 'Mariam Ahmed',
      'patientId': 'patient_006',
      'lastMessage': 'Good morning doctor!',
      'lastMessageTime': DateTime.now().subtract(const Duration(days: 3)),
      'unreadCount': 0,
      'patientAge': 26,
      'patientGender': 'Female',
    },
  ];

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
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Search functionality
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyChats.length,
        itemBuilder: (context, index) {
          final chat = dummyChats[index];
          return ChatTile(
            chatId: chat['chatId'],
            patientName: chat['patientName'],
            patientId: chat['patientId'],
            lastMessage: chat['lastMessage'],
            lastMessageTime: chat['lastMessageTime'],
            unreadCount: chat['unreadCount'],
            patientAge: chat['patientAge'],
            patientGender: chat['patientGender'],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorChatDetailScreen(
                    chatId: chat['chatId'],
                    patientName: chat['patientName'],
                    patientId: chat['patientId'],
                    patientAge: chat['patientAge'],
                    patientGender: chat['patientGender'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==================== CHAT TILE WIDGET ====================
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
              // Avatar
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

              // Content
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
