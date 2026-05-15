import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:shifa/Services/chat_service.dart';

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

  final ChatService _chatService = ChatService();

  List<dynamic> messages = [];

  bool isLoading = true;

  bool isSending = false;

  String error = '';

  @override
  void initState() {
    super.initState();

    _loadMessages();
  }

  // =========================
  // LOAD MESSAGES
  // =========================
  Future<void> _loadMessages() async {
    try {
      setState(() {
        isLoading = true;
      });

      final result = await _chatService.getMessages(widget.chatId);

      if (!mounted) return;

      setState(() {
        messages = result;

        isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        error = e.toString();

        isLoading = false;
      });
    }
  }

  // =========================
  // SEND MESSAGE
  // =========================
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty || isSending) {
      return;
    }

    try {
      setState(() {
        isSending = true;
      });

      final newMessage = await _chatService.sendMessage(
        chatId: widget.chatId,

        receiverId: widget.patientId,

        message: text,
      );

      if (!mounted) return;

      setState(() {
        messages.add(newMessage);

        isSending = false;
      });

      _messageController.clear();

      _scrollToBottom();
    } catch (e) {
      setState(() {
        isSending = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // =========================
  // SCROLL
  // =========================
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
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
        backgroundColor: Colors.teal,

        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),

          onPressed: () => Navigator.pop(context),
        ),

        title: Row(
          children: [
            CircleAvatar(
              radius: 20,

              backgroundColor: Colors.white,

              child: Text(
                widget.patientName[0].toUpperCase(),

                style: const TextStyle(
                  fontSize: 18,

                  fontWeight: FontWeight.bold,

                  color: Colors.teal,
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
                    '${widget.patientAge} years • ${widget.patientGender}',

                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),

            onPressed: () {},
          ),

          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),

            onPressed: () {},
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : error.isNotEmpty
          ? _buildError()
          : Column(
              children: [
                // =====================
                // MESSAGES
                // =====================
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,

                    padding: const EdgeInsets.all(16),

                    itemCount: messages.length,

                    itemBuilder: (context, index) {
                      final message = messages[index];

                      final isDoctor = message['senderRole'] == 'doctor';

                      return MessageBubble(
                        message: message['message'] ?? '',

                        timestamp:
                            DateTime.tryParse(message['createdAt'] ?? '') ??
                            DateTime.now(),

                        isDoctor: isDoctor,
                      );
                    },
                  ),
                ),

                // =====================
                // INPUT
                // =====================
                _buildInput(),
              ],
            ),
    );
  }

  // =========================
  // INPUT
  // =========================
  Widget _buildInput() {
    return Container(
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
                icon: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,

                        child: CircularProgressIndicator(
                          color: Colors.white,

                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),

                onPressed: isSending ? null : _sendMessage,
              ),
            ),
          ],
        ),
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
              onPressed: _loadMessages,

              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),

              child: const Text('Retry'),
            ),
          ],
        ),
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
        mainAxisAlignment: isDoctor
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,

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
