import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoctorChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String patientName;
  final String patientId;
  final int patientAge;
  final String patientGender;

  const DoctorChatDetailScreen({
    super.key,
    required this.chatId,
    required this.patientName,
    required this.patientId,
    required this.patientAge,
    required this.patientGender,
  });

  @override
  State<DoctorChatDetailScreen> createState() => _DoctorChatDetailScreenState();
}

class _DoctorChatDetailScreenState extends State<DoctorChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, dynamic>> messages;

  @override
  void initState() {
    super.initState();
    messages = _getDummyMessages(widget.chatId);
  }

  // ==================== DUMMY MESSAGES ====================
  List<Map<String, dynamic>> _getDummyMessages(String chatId) {
    // Different message sets for different chats
    if (chatId == 'chat_001') {
      return [
        {
          'senderId': widget.patientId,
          'message': 'Hello doctor, I wanted to follow up on my last visit.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
          'isDoctor': false,
        },
        {
          'senderId': 'doctor',
          'message': 'Hello Ahmed! How are you feeling today?',
          'timestamp': DateTime.now().subtract(const Duration(hours: 3, minutes: 2)),
          'isDoctor': true,
        },
        {
          'senderId': widget.patientId,
          'message': 'Much better! The medication is working well.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2, minutes: 50)),
          'isDoctor': false,
        },
        {
          'senderId': 'doctor',
          'message': 'That\'s great to hear! Continue taking it as prescribed.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
          'isDoctor': true,
        },
        {
          'senderId': widget.patientId,
          'message': 'Should I continue for the full 10 days?',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2, minutes: 40)),
          'isDoctor': false,
        },
        {
          'senderId': 'doctor',
          'message': 'Yes, please complete the full course even if you feel better.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2, minutes: 35)),
          'isDoctor': true,
        },
        {
          'senderId': widget.patientId,
          'message': 'Thank you doctor! I feel much better now.',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
          'isDoctor': false,
        },
      ];
    } else if (chatId == 'chat_002') {
      return [
        {
          'senderId': widget.patientId,
          'message': 'Good morning doctor!',
          'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
          'isDoctor': false,
        },
        {
          'senderId': 'doctor',
          'message': 'Good morning Sarah! How can I help you?',
          'timestamp': DateTime.now().subtract(const Duration(hours: 3, minutes: 55)),
          'isDoctor': true,
        },
        {
          'senderId': widget.patientId,
          'message': 'I received the prescription you sent.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 3, minutes: 50)),
          'isDoctor': false,
        },
        {
          'senderId': widget.patientId,
          'message': 'When should I take the medication?',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'isDoctor': false,
        },
      ];
    } else if (chatId == 'chat_003') {
      return [
        {
          'senderId': widget.patientId,
          'message': 'Hello doctor, thank you for yesterday\'s consultation.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
          'isDoctor': false,
        },
        {
          'senderId': 'doctor',
          'message': 'You\'re welcome Omar! I hope you\'re feeling better.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 5, minutes: 55)),
          'isDoctor': true,
        },
        {
          'senderId': widget.patientId,
          'message': 'Yes, the pain has reduced significantly.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 5, minutes: 50)),
          'isDoctor': false,
        },
        {
          'senderId': widget.patientId,
          'message': 'Can I schedule a follow-up appointment?',
          'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
          'isDoctor': false,
        },
      ];
    } else if (chatId == 'chat_004') {
      return [
        {
          'senderId': 'doctor',
          'message': 'Hello Fatma, I reviewed your test results.',
          'timestamp': DateTime.now().subtract(const Duration(days: 2)),
          'isDoctor': true,
        },
        {
          'senderId': widget.patientId,
          'message': 'Hello doctor! What do the results show?',
          'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 23, minutes: 55)),
          'isDoctor': false,
        },
        {
          'senderId': 'doctor',
          'message': 'Everything looks normal. No need to worry.',
          'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 23, minutes: 50)),
          'isDoctor': true,
        },
        {
          'senderId': widget.patientId,
          'message': 'That\'s a relief! Thank you so much.',
          'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 23, minutes: 45)),
          'isDoctor': false,
        },
        {
          'senderId': widget.patientId,
          'message': 'The test results have arrived.',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'isDoctor': false,
        },
      ];
    } else if (chatId == 'chat_005') {
      return [
        {
          'senderId': widget.patientId,
          'message': 'Doctor, I have a question about the treatment plan.',
          'timestamp': DateTime.now().subtract(const Duration(days: 3)),
          'isDoctor': false,
        },
        {
          'senderId': 'doctor',
          'message': 'Of course, what would you like to know?',
          'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 23, minutes: 55)),
          'isDoctor': true,
        },
        {
          'senderId': widget.patientId,
          'message': 'Is it normal to feel drowsy after taking the medication?',
          'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 23, minutes: 50)),
          'isDoctor': false,
        },
        {
          'senderId': widget.patientId,
          'message': 'Also, should I avoid certain foods?',
          'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 23, minutes: 48)),
          'isDoctor': false,
        },
        {
          'senderId': widget.patientId,
          'message': 'I have some questions about the treatment.',
          'timestamp': DateTime.now().subtract(const Duration(days: 2)),
          'isDoctor': false,
        },
      ];
    } else {
      return [
        {
          'senderId': widget.patientId,
          'message': 'Good morning doctor!',
          'timestamp': DateTime.now().subtract(const Duration(days: 3)),
          'isDoctor': false,
        },
        {
          'senderId': 'doctor',
          'message': 'Good morning! How can I assist you today?',
          'timestamp': DateTime.now().subtract(const Duration(days: 3, hours: 23, minutes: 55)),
          'isDoctor': true,
        },
      ];
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        'senderId': 'doctor',
        'message': _messageController.text.trim(),
        'timestamp': DateTime.now(),
        'isDoctor': true,
      });
    });

    _messageController.clear();
    
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return DateFormat('h:mm a').format(timestamp);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${DateFormat('h:mm a').format(timestamp)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.patientName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.patientName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${widget.patientAge} years, ${widget.patientGender}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isDoctor = message['isDoctor'] as bool;
                
                return MessageBubble(
                  message: message['message'],
                  timestamp: message['timestamp'],
                  isDoctor: isDoctor,
                );
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.teal,
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// ==================== MESSAGE BUBBLE ====================
class MessageBubble extends StatelessWidget {
  final String message;
  final DateTime timestamp;
  final bool isDoctor;

  const MessageBubble({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isDoctor,
  });

  String _formatTime(DateTime timestamp) {
    return DateFormat('h:mm a').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isDoctor ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isDoctor) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: Colors.teal.shade700,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDoctor ? Colors.teal : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isDoctor ? 20 : 4),
                  bottomRight: Radius.circular(isDoctor ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: isDoctor ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      color: isDoctor ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isDoctor) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.teal.shade700,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.medical_services,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
