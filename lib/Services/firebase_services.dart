import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= AUTH =================

  Future<void> signUp({
    required String email,
    required String password,
    required String role, // doctor | patient
    Map<String, dynamic>? extraData,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = cred.user!.uid;

    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection(role == 'doctor' ? 'doctors' : 'patients')
        .doc(uid)
        .set(extraData ?? {});
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = cred.user!.uid;
    final snap = await _firestore.collection('users').doc(uid).get();

    return snap.data()!['role'];
  }

  Future<void> logout() async => _auth.signOut();

  Future<String?> getCurrentUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final snap = await _firestore.collection('users').doc(uid).get();
    return snap.data()?['role'];
  }

  String get currentUserId => _auth.currentUser!.uid;

  Future<Map<String, dynamic>?> getDoctorById(String doctorId) async {
    final doc = await _firestore.collection('doctors').doc(doctorId).get();
    return doc.exists ? doc.data() : null;
  }

  Future<Map<String, dynamic>?> getPatientById(String patientId) async {
    final doc = await _firestore.collection('patients').doc(patientId).get();
    return doc.exists ? doc.data() : null;
  }

  Stream<QuerySnapshot> getDoctorAppointments() {
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: currentUserId)
        .orderBy('date')
        .snapshots();
  }

  Stream<QuerySnapshot> getPatientAppointments() {
    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: currentUserId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<Map<String, dynamic>?> getAppointmentById(String appointmentId) async {
    final doc = await _firestore
        .collection('appointments')
        .doc(appointmentId)
        .get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  }) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': status,
    });
  }

  Future<void> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String doctorSpecialty,
    required DateTime date,
    required String time,
  }) async {
    await _firestore.collection('appointments').add({
      'doctorId': doctorId,
      'patientId': currentUserId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'date': Timestamp.fromDate(date),
      'time': time,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getChatMessages(String appointmentId) {
    return _firestore
        .collection('appointments')
        .doc(appointmentId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<void> sendChatMessage({
    required String appointmentId,
    required String text,
  }) async {
    await _firestore
        .collection('appointments')
        .doc(appointmentId)
        .collection('messages')
        .add({
          'senderId': currentUserId,
          'text': text,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }
  // ================= ANALYTICS =================

  Future<int> countDoctorAppointmentsByStatus(String status) async {
    final snap = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: currentUserId)
        .where('status', isEqualTo: status)
        .get();

    return snap.docs.length;
  }

  Future<int> countTodayAppointments() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final snap = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: currentUserId)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          isLessThan: Timestamp.fromDate(end),
        )
        .get();

    return snap.docs.length;
  }
}
