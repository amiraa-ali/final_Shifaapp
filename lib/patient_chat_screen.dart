import 'package:flutter/material.dart';
import 'package:shifa/patient_home_screen.dart';
import 'patient_chat_details_screen.dart';

class PatientChatScreen extends StatelessWidget {
  const PatientChatScreen({super.key});

  static final List<Map<String, dynamic>> dummyChats = [
    {
      'chatId': 'chat_101',
      'doctorName': 'Dr. Sarah Ahmed',
      'doctorId': 'doctor_001',
      'specialty': 'Cardiology',
      'lastMessage':
          'Your test results look good. Keep up with the medication.',
      'lastMessageTime': DateTime.now().subtract(const Duration(minutes: 15)),
      'unreadCount': 1,
    },
    {
      'chatId': 'chat_102',
      'doctorName': 'Dr. Mohamed Hassan',
      'doctorId': 'doctor_002',
      'specialty': 'General Practice',
      'lastMessage': 'Thank you for visiting! Feel free to reach out anytime.',
      'lastMessageTime': DateTime.now().subtract(const Duration(hours: 3)),
      'unreadCount': 0,
    },
    {
      'chatId': 'chat_103',
      'doctorName': 'Dr. Laila Ibrahim',
      'doctorId': 'doctor_003',
      'specialty': 'Dermatology',
      'lastMessage': 'Apply the cream twice daily as prescribed.',
      'lastMessageTime': DateTime.now().subtract(const Duration(hours: 8)),
      'unreadCount': 2,
    },
    {
      'chatId': 'chat_104',
      'doctorName': 'Dr. Khaled Ali',
      'doctorId': 'doctor_004',
      'specialty': 'Orthopedics',
      'lastMessage': 'The X-ray shows significant improvement!',
      'lastMessageTime': DateTime.now().subtract(const Duration(days: 1)),
      'unreadCount': 0,
    },
    {
      'chatId': 'chat_105',
      'doctorName': 'Dr. Heba Mahmoud',
      'doctorId': 'doctor_005',
      'specialty': 'Pediatrics',
      'lastMessage': 'Your child is doing well. No need to worry.',
      'lastMessageTime': DateTime.now().subtract(const Duration(days: 2)),
      'unreadCount': 0,
    },
    {
      'chatId': 'chat_106',
      'doctorName': 'Dr. Omar Youssef',
      'doctorId': 'doctor_006',
      'specialty': 'Neurology',
      'lastMessage': 'Let\'s schedule a follow-up next week.',
      'lastMessageTime': DateTime.now().subtract(const Duration(days: 3)),
      'unreadCount': 3,
    },
  ];

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
            doctorName: chat['doctorName'],
            doctorId: chat['doctorId'],
            specialty: chat['specialty'],
            lastMessage: chat['lastMessage'],
            lastMessageTime: chat['lastMessageTime'],
            unreadCount: chat['unreadCount'],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PatientChatDetailScreen(
                    chatId: chat['chatId'],
                    doctorName: chat['doctorName'],
                    doctorId: chat['doctorId'],
                    specialty: chat['specialty'],
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
  final String doctorName;
  final String doctorId;
  final String specialty;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.chatId,
    required this.doctorName,
    required this.doctorId,
    required this.specialty,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
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
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xff39ab4a), Color(0xff009f93)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    doctorName.split(' ')[1][0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
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
