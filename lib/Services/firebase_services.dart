// lib/services/firebase_services.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== AUTH & USER STATE ====================

  /// Get current Firebase user
  User? getCurrentUser() => _auth.currentUser;

  /// Get current user ID
  String? getCurrentUserId() => _auth.currentUser?.uid;

  /// Get current user ID (alternative name for consistency)
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  /// Get current user as Future (for FutureBuilder)
  Future<User?> getUsercurrent() async {
    return _auth.currentUser;
  }

  /// Get user data (doctor or patient)
  Future<Map<String, dynamic>?> getUserData() async {
    final userId = getCurrentUserId();
    if (userId == null) return null;

    // Check if doctor
    final doctorData = await getDoctorProfile(userId);
    if (doctorData != null) {
      return {...doctorData, 'role': 'doctor'};
    }

    // Check if patient
    final patientData = await getPatientInfo(userId);
    if (patientData != null) {
      return {...patientData, 'role': 'patient'};
    }

    return null;
  }

  /// Get current user role
  Future<String?> getCurrentUserRole() async {
    final userId = getCurrentUserId();
    if (userId == null) return null;
    return await getUserRole(userId);
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Logout (alternative name)
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ==================== DOCTOR AUTH ====================

  Future<String> doctorSignIn(String email, String password) async {
  try {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password.trim(),
    );

    print("AUTH SUCCESS UID: ${userCredential.user!.uid}");

    // ✅ تأكيد إنه دكتور
    final doc = await _firestore
        .collection('doctors')
        .doc(userCredential.user!.uid)
        .get();

    if (!doc.exists) {
      await _auth.signOut();
      throw Exception('This account is not registered as a doctor');
    }

    // ✅ المهم هنا
    return 'doctor';
  } on FirebaseAuthException catch (e) {
    print("AUTH ERROR CODE: ${e.code}");
    print("AUTH ERROR MESSAGE: ${e.message}");
    throw Exception(e.message);
  } catch (e) {
    print('Doctor sign in error: $e');
    rethrow;
  }
}

Future<UserCredential> doctorSignUp({
  required String email,
  required String password,
  required String name,
  required String specialization,
  required String clinicLocation,
  required double fees,
}) async {
  try {
    UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password.trim(),
    );

    await _firestore
        .collection('doctors')
        .doc(userCredential.user!.uid)
        .set({
      'doctorId': userCredential.user!.uid,
      'name': name,
      'email': email.trim().toLowerCase(),
      'specialization': specialization,
      'clinicLocation': clinicLocation,
      'fees': fees,
      'rating': 0.0,
      'yearsExperience': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return userCredential;
  } catch (e) {
    print('Doctor sign up error: $e');
    rethrow;
  }
}
  // ==================== PATIENT AUTH ====================

 Future<String> patientSignIn(String email, String password) async {
  try {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password.trim(),
    );

    print("PATIENT AUTH SUCCESS UID: ${userCredential.user!.uid}");

    // ✅ تأكيد إنه Patient
    final doc = await _firestore
        .collection('patients')
        .doc(userCredential.user!.uid)
        .get();

    if (!doc.exists) {
      await _auth.signOut();
      throw Exception('This account is not registered as a patient');
    }

    // ✅ المهم
    return 'patient';
  } on FirebaseAuthException catch (e) {
    print("PATIENT AUTH ERROR CODE: ${e.code}");
    print("PATIENT AUTH ERROR MESSAGE: ${e.message}");
    throw Exception(e.message);
  } catch (e) {
    print('Patient sign in error: $e');
    rethrow;
  }
}

Future<UserCredential> patientSignUp({
  required String email,
  required String password,
  required String name,
  required String phone,
}) async {
  try {
    UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password.trim(),
    );

    await _firestore
        .collection('patients')
        .doc(userCredential.user!.uid)
        .set({
      'patientId': userCredential.user!.uid,
      'name': name,
      'email': email.trim().toLowerCase(),
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return userCredential;
  } catch (e) {
    print('Patient sign up error: $e');
    rethrow;
  }
}


  // ==================== DOCTOR PROFILE ====================

  Future<Map<String, dynamic>?> getDoctorProfile(String doctorId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('doctors')
          .doc(doctorId)
          .get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print('Get doctor profile error: $e');
      return null;
    }
  }

  Future<bool> updateDoctorProfile(
    String doctorId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('doctors').doc(doctorId).update(data);
      return true;
    } catch (e) {
      print('Update doctor profile error: $e');
      return false;
    }
  }

  // ==================== DOCTOR QUERIES ====================

  /// Get all doctors
  Stream<QuerySnapshot> getAllDoctors() {
    return _firestore.collection('doctors').snapshots();
  }

  /// Get doctors by specialty
  Stream<QuerySnapshot> getDoctorsBySpecialty(String specialty) {
    return _firestore
        .collection('doctors')
        .where('specialization', isEqualTo: specialty)
        .snapshots();
  }

  /// Get single doctor by ID
  Future<Map<String, dynamic>?> getDoctorById(String doctorId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('doctors')
          .doc(doctorId)
          .get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print('Get doctor by ID error: $e');
      return null;
    }
  }

  /// Search doctors by name
  Stream<QuerySnapshot> searchDoctorsByName(String searchQuery) {
    String searchEnd = '$searchQuery\uf8ff';
    return _firestore
        .collection('doctors')
        .where('name', isGreaterThanOrEqualTo: searchQuery)
        .where('name', isLessThan: searchEnd)
        .snapshots();
  }

  /// Get top-rated doctors
  Stream<QuerySnapshot> getTopRatedDoctors({int limit = 10}) {
    return _firestore
        .collection('doctors')
        .orderBy('rating', descending: true)
        .limit(limit)
        .snapshots();
  }

  // ==================== APPOINTMENTS ====================

  /// Create appointment with enhanced data
  Future<String?> createAppointment({
    required String patientId,
    required String doctorId,
    required DateTime appointmentDate,
    required String appointmentTime,
    required String serviceType,
    required double fees,
    required String paymentMethod,
    required String clinicLocation,
    String? patientName,
    String? doctorName,
    String? doctorSpecialty,
  }) async {
    try {
      // Get patient and doctor info if not provided
      if (patientName == null) {
        final patientData = await getPatientInfo(patientId);
        patientName = patientData?['name'] ?? 'Patient';
      }

      if (doctorName == null || doctorSpecialty == null) {
        final doctorData = await getDoctorProfile(doctorId);
        doctorName = doctorData?['name'] ?? 'Doctor';
        doctorSpecialty = doctorData?['specialization'] ?? serviceType;
      }

      DocumentReference appointmentRef = await _firestore
          .collection('appointments')
          .add({
            'patientId': patientId,
            'patientName': patientName,
            'doctorId': doctorId,
            'doctorName': doctorName,
            'doctorSpecialty': doctorSpecialty,
            'appointmentDate': Timestamp.fromDate(appointmentDate),
            'appointmentTime': appointmentTime,
            'serviceType': serviceType,
            'fees': fees,
            'paymentMethod': paymentMethod,
            'clinicLocation': clinicLocation,
            'status': 'upcoming',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return appointmentRef.id;
    } catch (e) {
      print('Create appointment error: $e');
      rethrow;
    }
  }

  /// Get all appointments for a doctor
  Stream<QuerySnapshot> getDoctorAppointments(String doctorId) {
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('appointmentDate', descending: false)
        .snapshots();
  }

  /// Get appointments for a patient
  Stream<QuerySnapshot> getPatientAppointments(String patientId) {
    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .orderBy('appointmentDate', descending: false)
        .snapshots();
  }

  /// Get today's appointments for doctor
  Stream<QuerySnapshot> getTodayAppointments(String doctorId) {
    DateTime now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day);
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where(
          'appointmentDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where('appointmentDate', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('appointmentDate')
        .snapshots();
  }

  /// Get upcoming appointments for patient
  Stream<QuerySnapshot> getUpcomingPatientAppointments(String patientId) {
    DateTime now = DateTime.now();
    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: 'upcoming')
        .where(
          'appointmentDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(now),
        )
        .orderBy('appointmentDate')
        .snapshots();
  }

  /// Get upcoming appointments for doctor
  Stream<QuerySnapshot> getUpcomingAppointments(String doctorId) {
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'upcoming')
        .orderBy('appointmentDate', descending: false)
        .snapshots();
  }

  /// Get completed appointments for doctor
  Stream<QuerySnapshot> getCompletedAppointments(String doctorId) {
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'completed')
        .orderBy('appointmentDate', descending: false)
        .snapshots();
  }

  /// Get cancelled appointments for doctor
  Stream<QuerySnapshot> getCancelledAppointments(String doctorId) {
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'cancelled')
        .orderBy('appointmentDate', descending: false)
        .snapshots();
  }

  /// Get appointment history (completed and cancelled) for patient
  Stream<QuerySnapshot> getAppointmentHistory(String patientId) {
    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .where('status', whereIn: ['completed', 'cancelled'])
        .orderBy('appointmentDate', descending: false)
        .snapshots();
  }

  /// Get completed appointments for patient
  Stream<QuerySnapshot> getPatientCompletedAppointments(String patientId) {
    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: 'completed')
        .orderBy('appointmentDate', descending: false)
        .snapshots();
  }

  /// Update appointment status
  Future<bool> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Update appointment error: $e');
      return false;
    }
  }

  /// Cancel appointment
  Future<bool> cancelAppointment(String appointmentId) async {
    return updateAppointmentStatus(appointmentId, 'cancelled');
  }

  /// Mark appointment as completed
  Future<bool> markAppointmentCompleted(String appointmentId) async {
    return updateAppointmentStatus(appointmentId, 'completed');
  }

  /// Get single appointment by ID
  Future<Map<String, dynamic>?> getAppointmentById(String appointmentId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print('Get appointment error: $e');
      return null;
    }
  }

  // ==================== CHAT ====================

  /// Get doctor's chats
  Stream<QuerySnapshot> getDoctorChats(String doctorId) {
    return _firestore
        .collection('chats')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  /// Get patient's chats
  Stream<QuerySnapshot> getPatientChats(String patientId) {
    return _firestore
        .collection('chats')
        .where('patientId', isEqualTo: patientId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  /// Get messages for a specific chat
  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  /// Send message
  Future<bool> sendMessage(
    String chatId,
    String senderId,
    String message,
  ) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
            'senderId': senderId,
            'message': message,
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
          });

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Send message error: $e');
      return false;
    }
  }

  /// Create or get chat between patient and doctor
  Future<String> getOrCreateChat({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
  }) async {
    // 1️⃣ Check if chat already exists
    final existingChat = await _firestore
        .collection('chats')
        .where('patientId', isEqualTo: patientId)
        .where('doctorId', isEqualTo: doctorId)
        .limit(1)
        .get();

    if (existingChat.docs.isNotEmpty) {
      return existingChat.docs.first.id;
    }

    // 2️⃣ Create new chat with REQUIRED fields
    final chatRef = await _firestore.collection('chats').add({
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    return chatRef.id;
  }

  /// Mark messages as read
  Future<bool> markMessagesAsRead(String chatId, String userId) async {
    try {
      QuerySnapshot unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: userId)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
      return true;
    } catch (e) {
      print('Mark messages as read error: $e');
      return false;
    }
  }

  // ==================== PATIENT PROFILE ====================

  /// Get patient information
  Future<Map<String, dynamic>?> getPatientInfo(String patientId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('patients')
          .doc(patientId)
          .get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print('Get patient info error: $e');
      return null;
    }
  }

  /// Update patient profile
  Future<bool> updatePatientProfile(
    String patientId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('patients').doc(patientId).update(data);
      return true;
    } catch (e) {
      print('Update patient profile error: $e');
      return false;
    }
  }

  // ==================== CATEGORIES ====================

  /// Get available specializations
  Future<List<String>> getAvailableSpecializations() async {
    try {
      QuerySnapshot doctors = await _firestore.collection('doctors').get();
      Set<String> specializations = {};

      for (var doc in doctors.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('specialization')) {
          specializations.add(data['specialization']);
        }
      }

      return specializations.toList();
    } catch (e) {
      print('Get specializations error: $e');
      return [];
    }
  }

  /// Get doctor count by specialty
  Future<Map<String, int>> getDoctorCountBySpecialty() async {
    try {
      QuerySnapshot doctors = await _firestore.collection('doctors').get();
      Map<String, int> counts = {};

      for (var doc in doctors.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('specialization')) {
          String specialty = data['specialization'];
          counts[specialty] = (counts[specialty] ?? 0) + 1;
        }
      }

      return counts;
    } catch (e) {
      print('Get doctor count error: $e');
      return {};
    }
  }

  // ==================== STATISTICS & ANALYTICS ====================

  /// Get total appointments count for doctor
  Future<int> getDoctorAppointmentCount(String doctorId) async {
    try {
      QuerySnapshot appointments = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();
      return appointments.docs.length;
    } catch (e) {
      print('Get appointment count error: $e');
      return 0;
    }
  }

  /// Get completed appointments count for doctor
  Future<int> getDoctorCompletedAppointments(String doctorId) async {
    try {
      QuerySnapshot appointments = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'completed')
          .get();
      return appointments.docs.length;
    } catch (e) {
      print('Get completed appointments error: $e');
      return 0;
    }
  }

  /// Get today's appointment count for doctor
  Future<int> getTodayAppointmentCount(String doctorId) async {
    try {
      DateTime now = DateTime.now();
      DateTime start = DateTime(now.year, now.month, now.day);
      DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

      QuerySnapshot appointments = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where(
            'appointmentDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          )
          .where(
            'appointmentDate',
            isLessThanOrEqualTo: Timestamp.fromDate(end),
          )
          .get();

      return appointments.docs.length;
    } catch (e) {
      print('Get today appointment count error: $e');
      return 0;
    }
  }

  /// Get upcoming appointment count for doctor
  Future<int> getUpcomingAppointmentCount(String doctorId) async {
    try {
      DateTime now = DateTime.now();
      QuerySnapshot appointments = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'upcoming')
          .where(
            'appointmentDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(now),
          )
          .get();

      return appointments.docs.length;
    } catch (e) {
      print('Get upcoming appointment count error: $e');
      return 0;
    }
  }

  /// Get total unique patients count for doctor
  Future<int> getTotalPatientsCount(String doctorId) async {
    try {
      QuerySnapshot appointments = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      Set<String> uniquePatients = {};
      for (var doc in appointments.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('patientId')) {
          uniquePatients.add(data['patientId']);
        }
      }

      return uniquePatients.length;
    } catch (e) {
      print('Get total patients count error: $e');
      return 0;
    }
  }

  /// Get monthly revenue for doctor
  Future<double> getMonthlyRevenue(String doctorId) async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      QuerySnapshot appointments = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', whereIn: ['completed', 'upcoming'])
          .where(
            'appointmentDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .where(
            'appointmentDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth),
          )
          .get();

      double total = 0.0;
      for (var doc in appointments.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('fees')) {
          total += (data['fees'] as num).toDouble();
        }
      }

      return total;
    } catch (e) {
      print('Get monthly revenue error: $e');
      return 0.0;
    }
  }
  // ==================== PASSWORD RESET ====================

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Send password reset email error: $e');
      return false;
    }
  }
  

  // ==================== USER ROLE CHECK ====================

  /// Check if user is a doctor
  Future<bool> isDoctor(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('doctors')
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Check doctor role error: $e');
      return false;
    }
  }

  /// Check if user is a patient
  Future<bool> isPatient(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('patients')
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Check patient role error: $e');
      return false;
    }
  }

  /// Get user role
  Future<String?> getUserRole(String userId) async {
    try {
      if (await isDoctor(userId)) {
        return 'doctor';
      } else if (await isPatient(userId)) {
        return 'patient';
      }
      return null;
    } catch (e) {
      print('Get user role error: $e');
      return null;
    }
  }

  // ==================== DOCTOR AVAILABILITY ====================

  /// Set doctor availability for specific dates/times
  Future<bool> setDoctorAvailability({
    required String doctorId,
    required DateTime date,
    required List<String> availableTimes,
  }) async {
    try {
      String dateKey =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      await _firestore
          .collection('doctors')
          .doc(doctorId)
          .collection('availability')
          .doc(dateKey)
          .set({
            'date': Timestamp.fromDate(date),
            'availableTimes': availableTimes,
            'bookedTimes': [],
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return true;
    } catch (e) {
      print('Set availability error: $e');
      return false;
    }
  }

  /// Get doctor availability for a specific date
  Future<Map<String, dynamic>?> getDoctorAvailability(
    String doctorId,
    DateTime date,
  ) async {
    try {
      String dateKey =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      DocumentSnapshot doc = await _firestore
          .collection('doctors')
          .doc(doctorId)
          .collection('availability')
          .doc(dateKey)
          .get();

      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print('Get availability error: $e');
      return null;
    }
  }

  /// Book a time slot
  Future<bool> bookTimeSlot({
    required String doctorId,
    required DateTime date,
    required String time,
  }) async {
    try {
      String dateKey =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      await _firestore
          .collection('doctors')
          .doc(doctorId)
          .collection('availability')
          .doc(dateKey)
          .update({
            'bookedTimes': FieldValue.arrayUnion([time]),
          });

      return true;
    } catch (e) {
      print('Book time slot error: $e');
      return false;
    }
  }

  Future<String> bookAppointmentTransaction({
    required String patientId,
    required String doctorId,
    required DateTime appointmentDate,
    required String appointmentTime,
    required String serviceType,
    required double fees,
    required String paymentMethod,
    required String clinicLocation,
    required String doctorName,
    required String doctorSpecialty,
  }) async {
    // 🔹 SAFELY GET PATIENT NAME
    final patientData = await getPatientInfo(patientId);
    final patientName = patientData?['name'] ?? 'Patient';

    final dateKey =
        "${appointmentDate.year}-${appointmentDate.month.toString().padLeft(2, '0')}-${appointmentDate.day.toString().padLeft(2, '0')}";

    final availabilityRef = _firestore
        .collection('doctors')
        .doc(doctorId)
        .collection('availability')
        .doc(dateKey);

    final appointmentsRef = _firestore.collection('appointments').doc();

    return _firestore.runTransaction((transaction) async {
      // 1️⃣ READ AVAILABILITY
      final availabilitySnap = await transaction.get(availabilityRef);

      if (!availabilitySnap.exists) {
        throw Exception("Doctor availability not set for this date");
      }

      final data = availabilitySnap.data() as Map<String, dynamic>;

      final List<String> bookedTimes = (data['bookedTimes'] as List? ?? [])
          .whereType<String>()
          .toList();

      // 2️⃣ CHECK SLOT
      if (bookedTimes.contains(appointmentTime)) {
        throw Exception("Time slot already booked");
      }

      // 3️⃣ BOOK SLOT
      transaction.update(availabilityRef, {
        'bookedTimes': FieldValue.arrayUnion([appointmentTime]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 4️⃣ CREATE APPOINTMENT
      transaction.set(appointmentsRef, {
        'patientId': patientId,
        'patientName': patientName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'doctorSpecialty': doctorSpecialty,
        'appointmentDate': Timestamp.fromDate(appointmentDate),
        'appointmentTime': appointmentTime,
        'serviceType': serviceType,
        'fees': fees,
        'paymentMethod': paymentMethod,
        'clinicLocation': clinicLocation,
        'status': 'upcoming',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // ✅ RETURN APPOINTMENT ID
      return appointmentsRef.id;
    });
  }
}



