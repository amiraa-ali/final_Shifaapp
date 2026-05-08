import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatientChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String doctorName;
  final String doctorId;
  final String specialty;

  const PatientChatDetailScreen({
    super.key,
    required this.chatId,
    required this.doctorName,
    required this.doctorId,
    required this.specialty,
  });

  @override
  State<PatientChatDetailScreen> createState() =>
      _PatientChatDetailScreenState();
}

class _PatientChatDetailScreenState extends State<PatientChatDetailScreen> {
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
    if (chatId == 'chat_101') {
      return [
        {
          'senderId': 'patient',
          'message': 'Good morning doctor! I wanted to discuss my test results.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'isPatient': true,
        },
        {
          'senderId': widget.doctorId,
          'message': 'Good morning! I\'ve reviewed your results.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 58)),
          'isPatient': false,
        },
        {
          'senderId': widget.doctorId,
          'message': 'Your cholesterol levels have improved significantly!',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 57)),
          'isPatient': false,
        },
        {
          'senderId': 'patient',
          'message': 'That\'s wonderful news! Thank you doctor 😊',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
          'isPatient': true,
        },
        {
          'senderId': widget.doctorId,
          'message': 'Keep taking your medication as prescribed.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
          'isPatient': false,
        },
        {
          'senderId': 'patient',
          'message': 'Should I continue with the same dosage?',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
          'isPatient': true,
        },
        {
          'senderId': widget.doctorId,
          'message': 'Yes, continue with the current dosage.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
          'isPatient': false,
        },
        {
          'senderId': widget.doctorId,
          'message': 'Your test results look good. Keep up with the medication.',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
          'isPatient': false,
        },
      ];
    } else if (chatId == 'chat_102') {
      return [
        {
          'senderId': 'patient',
          'message': 'Hello doctor, thank you for yesterday\'s consultation.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
          'isPatient': true,
        },
        {
          'senderId': widget.doctorId,
          'message': 'You\'re welcome! How are you feeling today?',
          'timestamp': DateTime.now().subtract(const Duration(hours: 4, minutes: 55)),
          'isPatient': false,
        },
        {
          'senderId': 'patient',
          'message': 'Much better! The fever has gone down.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 4, minutes: 50)),
          'isPatient': true,
        },
        {
          'senderId': widget.doctorId,
          'message': 'Great! Continue the antibiotics for the full course.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 4, minutes: 45)),
          'isPatient': false,
        },
        {
          'senderId': 'patient',
          'message': 'Will do. Should I schedule a follow-up?',
          'timestamp': DateTime.now().subtract(const Duration(hours: 4, minutes: 40)),
          'isPatient': true,
        },
        {
          'senderId': widget.doctorId,
          'message': 'Let\'s see how you feel in a week. If symptoms persist, come back.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 4, minutes: 35)),
          'isPatient': false,
        },
        {
          'senderId': widget.doctorId,
          'message': 'Thank you for visiting! Feel free to reach out anytime.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
          'isPatient': false,
        },
      ];
    } else if (chatId == 'chat_103') {
      return [
        {
          'senderId': 'patient',
          'message': 'Doctor, the rash is getting worse.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 10)),
          'isPatient': true,
        },
        {
          'senderId': widget.doctorId,
          'message': 'I see. Have you been applying the cream I prescribed?',
          'timestamp': DateTime.now().subtract(const Duration(hours: 9, minutes: 55)),
          'isPatient': false,
        },
        {
          'senderId': 'patient',
          'message': 'Yes, but only once a day.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 9, minutes: 50)),
          'isPatient': true,
        },
        {
          'senderId': widget.doctorId,
          'message': 'That\'s the issue. Apply it twice daily - morning and evening.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 9, minutes: 45)),
          'isPatient': false,
        },
        {
          'senderId': 'patient',
          'message': 'Oh! I misunderstood. I\'ll do that now.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 9, minutes: 40)),
          'isPatient': true,
        },
        {
          'senderId': widget.doctorId,
          'message': 'Also avoid scratching. It can cause infection.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 9, minutes: 35)),
          'isPatient': false,
        },
        {
          'senderId': widget.doctorId,
          'message': 'Apply the cream twice daily as prescribed.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 8)),
          'isPatient': false,
        },
      ];
    } else if (chatId == 'chat_104') {
      return [
        {
          'senderId': 'patient',
          'message': 'Good afternoon doctor! Got my X-ray done today.',
          'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 4)),
          'isPatient': true,
        },
        {
          'senderId': widget.doctorId,
          'message': 'Perfect timing! Let me review it.',
          'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 3, minutes: 55)),
          'isPatient': false,
        },
        {
          'senderId': widget.doctorId,
          'message': 'The fracture is healing nicely!',
          'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 3, minutes: 50)),
          'isPatient': false,
        },
        {
          'senderId': 'patient',
          'message': 'That\'s a relief! When can I start exercising?',
          'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 3, minutes: 45)),
          'isPatient': true,
        },
        {
          'senderId': widget.doctorId,
          'message': 'Give it another 2 weeks, then start with light exercises.',
          'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 3, minutes: 40)),
          'isPatient': false,
        },
        {
          'senderId': widget.doctorId,
          'message': 'The X-ray shows significant improvement!',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'isPatient': false,
        },
      ];
    } else if (chatId == 'chat_105') {
      return [
        {
          'senderId': 'patient',
          'message': 'Hello doctor, my son had a fever this morning.',
          'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 6)),
          'isPatient': true,
        },
        {
          'senderId': widget.doctorId,
          'message': 'How high is the temperature?',
          'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 5, minutes: 55)),
          'isPatient': false,
        },
        {
          'senderId': 'patient',
          'message': '38.5°C. He\'s also complaining of a sore throat.',
          'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 5, minutes: 50)),
          'isPatient': true,
        },
        {
          'senderId': widget.doctorId,
          'message': 'Give him paracetamol for fever and plenty of fluids.',
          'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 5, minutes: 45)),
          'isPatient': false,
        },
        {
          'senderId': 'patient',
          'message': 'Should I bring him in for a check-up?',
          'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 5, minutes: 40)),
          'isPatient': true,
        },
        {
          'senderId': widget.doctorId,
          'message': 'Monitor him for 24 hours. If fever persists, yes.',
          'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 5, minutes: 35)),
          'isPatient': false,
        },
        {
          'senderId': widget.doctorId,
          'message': 'Your child is doing well. No need to worry.',
          'timestamp': DateTime.now().subtract(const Duration(days: 2)),
          'isPatient': false,
        },
      ];
    } else {
      return [
        {
          'senderId': 'patient',
          'message': 'Hello doctor, I need to discuss my headaches.',
          'timestamp': DateTime.now().subtract(const Duration(days: 4)),
          'isPatient': true,
        },
        {
          'senderId': widget.doctorId,
          'message': 'Tell me more about when they occur.',
          'timestamp': DateTime.now().subtract(const Duration(days: 3, hours: 23, minutes: 55)),
          'isPatient': false,
        },
        {
          'senderId': 'patient',
          'message': 'Usually in the evening after work.',
          'timestamp': DateTime.now().subtract(const Duration(days: 3, hours: 23, minutes: 50)),
          'isPatient': true,
        },
        {
          'senderId': widget.doctorId,
          'message': 'Sounds like tension headaches. Try to take breaks and reduce screen time.',
          'timestamp': DateTime.now().subtract(const Duration(days: 3, hours: 23, minutes: 45)),
          'isPatient': false,
        },
        {
          'senderId': widget.doctorId,
          'message': 'Let\'s schedule a follow-up next week.',
          'timestamp': DateTime.now().subtract(const Duration(days: 3)),
          'isPatient': false,
        },
      ];
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        'senderId': 'patient',
        'message': _messageController.text.trim(),
        'timestamp': DateTime.now(),
        'isPatient': true,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
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
                  widget.doctorName.split(' ')[1][0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff009f93),
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
                    widget.doctorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    widget.specialty,
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
                final isPatient = message['isPatient'] as bool;

                return MessageBubble(
                  message: message['message'],
                  timestamp: message['timestamp'],
                  isPatient: isPatient,
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
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xff39ab4a), Color(0xff009f93)],
                      ),
                    ),
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
  final bool isPatient;

  const MessageBubble({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isPatient,
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
            isPatient ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isPatient) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xff39ab4a), Color(0xff009f93)],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.medical_services,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isPatient
                    ? const LinearGradient(
                        colors: [Color(0xff39ab4a), Color(0xff009f93)],
                      )
                    : null,
                color: isPatient ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isPatient ? 20 : 4),
                  bottomRight: Radius.circular(isPatient ? 4 : 20),
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
                      color: isPatient ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      color: isPatient ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isPatient) ...[
            const SizedBox(width: 8),
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
          ],
        ],
      ),
    );
  }
}
