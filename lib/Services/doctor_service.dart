import 'package:dio/dio.dart';

class DoctorService {
  final Dio dio = Dio();

  static const baseUrl = "http://10.0.2.2:5000/api";

  // =========================
  // GET ALL DOCTORS
  // =========================
  Future<List<dynamic>> getDoctors() async {
    try {
      final response = await dio.get("$baseUrl/doctors");

      return response.data["data"] ?? [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Failed to load doctors",
      );
    }
  }

  // =========================
  // GET DOCTOR DETAILS
  // =========================
  Future<Map<String, dynamic>> getDoctorById(
    String doctorId,
  ) async {
    try {
      final response = await dio.get(
        "$baseUrl/doctors/$doctorId",
      );

      return response.data["data"];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Failed to load doctor",
      );
    }
  }

  // =========================
  // SEARCH DOCTORS
  // =========================
  Future<List<dynamic>> searchDoctors(
    String query,
  ) async {
    try {
      final response = await dio.get(
        "$baseUrl/doctors/search?q=$query",
      );

      return response.data["data"] ?? [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Search failed",
      );
    }
  }

  // =========================
  // FILTER BY SPECIALIZATION
  // =========================
  Future<List<dynamic>>
      getDoctorsBySpecialization(
    String specialization,
  ) async {
    try {
      final response = await dio.get(
        "$baseUrl/doctors/specialization/$specialization",
      );

      return response.data["data"] ?? [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to load doctors",
      );
    }
  }
}