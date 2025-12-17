import 'package:flutter/material.dart';
import 'patient_home_screen.dart';

class PatientChatScreen extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String? doctorImageUrl;
  final String? appointmentId;
  // يمكنك إضافة مسار صورة الطبيب هنا إذا أردت عرضها

  const PatientChatScreen({
    super.key,
    this.doctorName = 'Dr. Sarah Johnson', // قيمة افتراضية
    this.specialty = 'Cardiologist', // قيمة افتراضية
    this.doctorImageUrl,
    this.appointmentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PatientHomeScreen()),
          ), // للرجوع للخلف
        ),
        title: Row(
          children: [
            // صورة الطبيب (Avatar)
            const CircleAvatar(
              backgroundColor: Colors.grey,
              // يمكنك استخدام Image.asset أو NetworkImage هنا
              child: Text('SJ'), // اختصار الاسم إذا لم تتوفر صورة
            ),
            const SizedBox(width: 10),
            // تفاصيل الطبيب
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  specialty,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),

      // جسم الصفحة (الفقرات والمحادثات)
      body: Column(
        children: <Widget>[
          // منطقة عرض الرسائل
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10.0),
              children: const <Widget>[
                // مثال على الرسائل (يمكن استبدالها بقائمة رسائل ديناميكية)
                MessageBubble(
                  text: 'Hello! How can I help you today?',
                  time: '10:30 AM',
                  isMe: false,
                ),
                MessageBubble(
                  text:
                      'Hi Doctor, I\'ve been experiencing some chest discomfort lately.',
                  time: '10:32 AM',
                  isMe: true,
                ),
                MessageBubble(
                  text:
                      'I understand. Can you describe the discomfort? When did it start?',
                  time: '10:33 AM',
                  isMe: false,
                ),
                MessageBubble(
                  text:
                      'It started about 3 days ago. It\'s a mild pain that comes and goes.',
                  time: '10:35 AM',
                  isMe: true,
                ),
                MessageBubble(
                  text:
                      'I see. I\'d recommend scheduling an in-person consultation so we can run some tests. Would you like to book an appointment?',
                  time: '10:37 AM',
                  isMe: false,
                ),
              ],
            ),
          ),

          // حقل إدخال الرسالة
          _buildMessageInput(),
        ],
      ),
    );
  }

  // دالة بناء حقل إدخال الرسالة
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          // أيقونة المشبك (لإرفاق ملفات)
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.grey),
            onPressed: () {
              // منطق إرفاق الملفات
            },
          ),
          // حقل النص
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
            ),
          ),
          // زر الإرسال
          IconButton(
            icon: const Icon(
              Icons.send,
              color: Color(0xFF1ABC9C),
            ), // نفس لون الزر السابق
            onPressed: () {
              // منطق إرسال الرسالة
            },
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------

// مكون فقاعة الرسالة القابلة لإعادة الاستخدام (Message Bubble Widget)
class MessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    // محاذاة الفقاعة (يمين إذا كانت مني، يسار إذا كانت من الطرف الآخر)
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: <Widget>[
          Material(
            elevation: 2.0,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(15.0),
              topRight: const Radius.circular(15.0),
              // تحديد انحناء الزاوية السفلية بناءً على المرسل
              bottomLeft: isMe
                  ? const Radius.circular(15.0)
                  : const Radius.circular(3.0),
              bottomRight: isMe
                  ? const Radius.circular(3.0)
                  : const Radius.circular(15.0),
            ),
            color: isMe
                ? const Color(0xFF2ECC71)
                : Colors.white, // ألوان الفقاعات
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 15.0,
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
          // الوقت أسفل الرسالة
          Padding(
            padding: EdgeInsets.only(
              top: 4.0,
              right: isMe ? 8.0 : 0,
              left: isMe ? 0 : 8.0,
            ),
            child: Text(
              time,
              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
