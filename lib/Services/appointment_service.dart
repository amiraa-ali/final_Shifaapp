import 'package:dio/dio.dart';

import 'auth_service.dart';

class AppointmentService {
  final Dio dio = Dio();

  final AuthService authService = AuthService();

  static const baseUrl = "http://10.0.2.2:5000/api";

  // =========================
  // CREATE APPOINTMENT
  // =========================
  Future<Map<String, dynamic>> createAppointment({
    required String doctorId,
    required String appointmentDate,
    String notes = '',
  }) async {
    try {
      final token = await authService.getToken();

      final response = await dio.post(
        "$baseUrl/appointments",

        data: {
          "doctorId": doctorId,
          "appointmentDate": appointmentDate,
          "notes": notes,
        },

        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Failed to create appointment",
      );
    }
  }

  // =========================
  // GET PATIENT APPOINTMENTS
  // =========================
  Future<List<dynamic>> getPatientAppointments({String filter = "all"}) async {
    try {
      final token = await authService.getToken();

      final response = await dio.get(
        "$baseUrl/appointments/patient?filter=$filter",

        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.data["appointments"] ?? [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Failed to load appointments",
      );
    }
  }

  // =========================
  // GET DOCTOR APPOINTMENTS
  // =========================
  Future<List<dynamic>> getDoctorAppointments({String filter = "all"}) async {
    try {
      final token = await authService.getToken();

      final response = await dio.get(
        "$baseUrl/appointments/doctor?filter=$filter",

        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.data["appointments"] ?? [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Failed to load doctor appointments",
      );
    }
  }

  // =========================
  // TODAY APPOINTMENTS
  // =========================
  Future<List<dynamic>> getTodayAppointments() async {
    return await getDoctorAppointments(filter: "today");
  }

  // =========================
  // UPCOMING APPOINTMENTS
  // =========================
  Future<List<dynamic>> getUpcomingAppointments() async {
    return await getDoctorAppointments(filter: "upcoming");
  }

  // =========================
  // COMPLETED APPOINTMENTS
  // =========================
  Future<List<dynamic>> getCompletedAppointments() async {
    return await getDoctorAppointments(filter: "completed");
  }

  // =========================
  // CANCELLED APPOINTMENTS
  // =========================
  Future<List<dynamic>> getCancelledAppointments() async {
    return await getDoctorAppointments(filter: "cancelled");
  }

  // =========================
  // CANCEL APPOINTMENT
  // =========================
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      final token = await authService.getToken();

      await dio.put(
        "$baseUrl/appointments/$appointmentId/cancel",

        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Failed to cancel appointment",
      );
    }
  }

  // =========================
  // CONFIRM APPOINTMENT
  // =========================
  Future<void> confirmAppointment(String appointmentId) async {
    try {
      final token = await authService.getToken();

      await dio.put(
        "$baseUrl/appointments/$appointmentId/confirm",

        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Failed to confirm appointment",
      );
    }
  }

  // =========================
  // COMPLETE APPOINTMENT
  // =========================
  Future<void> completeAppointment(String appointmentId) async {
    try {
      final token = await authService.getToken();

      await dio.put(
        "$baseUrl/appointments/$appointmentId/complete",

        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Failed to complete appointment",
      );
    }
  }
}
