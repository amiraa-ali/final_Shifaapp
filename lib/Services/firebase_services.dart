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
    await signOut();
  }

  /// Sign in with LinkedIn (using OAuth)
  /// Note: LinkedIn requires OAuth setup and web authentication
  Future<UserCredential?> signInWithLinkedIn() async {
    try {
      // LinkedIn OAuth Provider
      final OAuthProvider linkedInProvider = OAuthProvider('oidc.linkedin');

      // Sign in with LinkedIn
      return await _auth.signInWithProvider(linkedInProvider);
    } catch (e) {
      print('LinkedIn sign in error: $e');
      rethrow;
    }
  }

  /// Create patient account from social auth
  Future<bool> createPatientFromSocialAuth(User user) async {
    try {
      // Check if patient already exists
      final doc = await _firestore.collection('patients').doc(user.uid).get();

      if (!doc.exists) {
        // Create new patient document
        await _firestore.collection('patients').doc(user.uid).set({
          'patientId': user.uid,
          'name': user.displayName ?? 'Patient',
          'email': user.email ?? '',
          'phone': user.phoneNumber ?? '',
          'photoUrl': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      print('Create patient from social auth error: $e');
      return false;
    }
  }

  /// Create doctor account from social auth
  Future<bool> createDoctorFromSocialAuth(
    User user,
    String specialization,
  ) async {
    try {
      // Check if doctor already exists
      final doc = await _firestore.collection('doctors').doc(user.uid).get();

      if (!doc.exists) {
        // Create new doctor document
        await _firestore.collection('doctors').doc(user.uid).set({
          'doctorId': user.uid,
          'name': user.displayName ?? 'Doctor',
          'email': user.email ?? '',
          'specialization': specialization,
          'clinicLocation': 'Clinic',
          'fees': 200.0,
          'phone': user.phoneNumber ?? '',
          'photoUrl': user.photoURL ?? '',
          'rating': 0.0,
          'yearsExperience': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      print('Create doctor from social auth error: $e');
      return false;
    }
  }

  // ==================== DOCTOR AUTH ====================

  Future<UserCredential> doctorSignIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );

      print("AUTH SUCCESS UID: ${userCredential.user!.uid}");

      // Verify user is a doctor
      final doc = await _firestore
          .collection('doctors')
          .doc(userCredential.user!.uid)
          .get();

      if (!doc.exists) {
        await _auth.signOut();
        throw Exception('This account is not registered as a doctor');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("AUTH ERROR CODE: ${e.code}");
      print("AUTH ERROR MESSAGE: ${e.message}");
      rethrow;
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
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim().toLowerCase(),
            password: password.trim(),
          );

      await _firestore.collection('doctors').doc(userCredential.user!.uid).set({
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

  /// Check if email exists in doctors collection
  Future<bool> emailExistsAsDoctor(String email) async {
    try {
      final query = await _firestore
          .collection('doctors')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('Check doctor email error: $e');
      return false;
    }
  }

  // ==================== PATIENT AUTH ====================

  Future<UserCredential> patientSignIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );

      print("PATIENT AUTH SUCCESS UID: ${userCredential.user!.uid}");

      // Verify user is a patient
      final doc = await _firestore
          .collection('patients')
          .doc(userCredential.user!.uid)
          .get();

      if (!doc.exists) {
        await _auth.signOut();
        throw Exception('This account is not registered as a patient');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("PATIENT AUTH ERROR CODE: ${e.code}");
      print("PATIENT AUTH ERROR MESSAGE: ${e.message}");
      rethrow;
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
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
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

  Stream<QuerySnapshot> getAllDoctors() {
    return _firestore.collection('doctors').snapshots();
  }

  Stream<QuerySnapshot> getDoctorsBySpecialty(String specialty) {
    return _firestore
        .collection('doctors')
        .where('specialization', isEqualTo: specialty)
        .snapshots();
  }

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

  Stream<QuerySnapshot> searchDoctorsByName(String searchQuery) {
    String searchEnd = '$searchQuery\uf8ff';
    return _firestore
        .collection('doctors')
        .where('name', isGreaterThanOrEqualTo: searchQuery)
        .where('name', isLessThan: searchEnd)
        .snapshots();
  }

  Stream<QuerySnapshot> getTopRatedDoctors({int limit = 10}) {
    return _firestore
        .collection('doctors')
        .orderBy('rating', descending: true)
        .limit(limit)
        .snapshots();
  }

  // ==================== APPOINTMENTS ====================

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

  // ==================== APPOINTMENTS QUERIES ====================

  Stream<QuerySnapshot> getDoctorAppointments(String doctorId) {
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('appointmentDate', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getPatientAppointments(String patientId) {
    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .orderBy('appointmentDate', descending: false)
        .snapshots();
  }

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

  Stream<QuerySnapshot> getUpcomingPatientAppointments(String patientId) {
    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: 'upcoming')
        .orderBy('appointmentDate', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getUpcomingAppointments(String doctorId) {
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'upcoming')
        .orderBy('appointmentDate', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getCompletedAppointments(String doctorId) {
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'completed')
        .orderBy('appointmentDate', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getDoctorAllAppointments(String doctorId) {
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots();
  }

  Stream<QuerySnapshot> getCancelledAppointments(String doctorId) {
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'cancelled')
        .orderBy('appointmentDate', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getAppointmentHistory(String patientId) {
    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .where('status', whereIn: ['completed', 'cancelled'])
        .orderBy('appointmentDate', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getPatientCompletedAppointments(String patientId) {
    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: 'completed')
        .orderBy('appointmentDate', descending: true)
        .snapshots();
  }

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

  Future<bool> cancelAppointment(String appointmentId) async {
    return updateAppointmentStatus(appointmentId, 'cancelled');
  }

  Future<bool> markAppointmentCompleted(String appointmentId) async {
    return updateAppointmentStatus(appointmentId, 'completed');
  }

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

  Stream<QuerySnapshot> getDoctorChats(String doctorId) {
    return _firestore
        .collection('chats')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getPatientChats(String patientId) {
    return _firestore
        .collection('chats')
        .where('patientId', isEqualTo: patientId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

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

  Future<String> getOrCreateChat({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
  }) async {
    final existingChat = await _firestore
        .collection('chats')
        .where('patientId', isEqualTo: patientId)
        .where('doctorId', isEqualTo: doctorId)
        .limit(1)
        .get();

    if (existingChat.docs.isNotEmpty) {
      return existingChat.docs.first.id;
    }

    final chatRef = await _firestore.collection('chats').add({
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return chatRef.id;
  }

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

  // ==================== STATISTICS & ANALYTICS ====================

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
}
