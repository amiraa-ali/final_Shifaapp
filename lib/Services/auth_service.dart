import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

class AuthService {
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),

      receiveTimeout: const Duration(seconds: 30),

      sendTimeout: const Duration(seconds: 30),

      headers: {"Content-Type": "application/json"},
    ),
  );

  final storage = const FlutterSecureStorage();

  static const baseUrl = "http://192.168.1.16:5000/api";

  // =========================
  // LOGIN
  // =========================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        "$baseUrl/auth/login",

        data: {"email": email, "password": password},
      );

      print("LOGIN RESPONSE:");
      print(response.data);

      final token = response.data["data"]["token"];

      await storage.write(key: "token", value: token);

      return response.data;
    } on DioException catch (e) {
      print("LOGIN ERROR:");
      print(e.response?.data);

      throw Exception(e.response?.data["message"] ?? "Login failed");
    }
  }

  // =========================
  // PATIENT SIGNUP
  // =========================
  Future<Map<String, dynamic>> patientSignup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        "$baseUrl/auth/register",

        data: {
          "name": name,
          "email": email,
          "password": password,
          "role": "patient",
        },
      );

      print("PATIENT SIGNUP RESPONSE:");
      print(response.data);

      final token = response.data["data"]["token"];

      await storage.write(key: "token", value: token);

      return response.data;
    } on DioException catch (e) {
      print("PATIENT SIGNUP ERROR:");
      print(e.response?.data);

      throw Exception(e.response?.data.toString() ?? "Patient signup failed");
    }
  }

  // =========================
  // DOCTOR SIGNUP
  // =========================
  Future<Map<String, dynamic>> doctorSignup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String specialization,
    required String clinicLocation,
    required String fees,
  }) async {
    try {
      final response = await dio.post(
        "$baseUrl/auth/register",

        data: {
          "name": name,
          "email": email,
          "password": password,
          "role": "doctor",
        },
      );

      print("DOCTOR SIGNUP RESPONSE:");
      print(response.data);

      final token = response.data["data"]["token"];

      await storage.write(key: "token", value: token);

      return response.data;
    } on DioException catch (e) {
      print("BASE URL:");
      print(baseUrl);

      print("ERROR TYPE:");
      print(e.type);

      print("ERROR MESSAGE:");
      print(e.message);

      print("ERROR RESPONSE:");
      print(e.response?.data);

      throw Exception("Connection Error");
    }
  }

  // =========================
  // GET TOKEN
  // =========================
  Future<String?> getToken() async {
    return await storage.read(key: "token");
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    await storage.delete(key: "token");
  }

  // =========================
  // GET PATIENT PROFILE
  // =========================
  Future<Map<String, dynamic>> getPatientProfile() async {
    try {
      final token = await getToken();

      final response = await dio.get(
        "$baseUrl/patients/profile",

        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.data;
    } on DioException catch (e) {
      print(e.response?.data);

      throw Exception(
        e.response?.data["message"] ?? "Failed to load patient profile",
      );
    }
  }

  // =========================
  // UPDATE PATIENT PROFILE
  // =========================
  Future<Map<String, dynamic>> updatePatientProfile({
    required String name,
    required String phone,
    required String location,
    required String dateOfBirth,
  }) async {
    try {
      final token = await getToken();

      final response = await dio.put(
        "$baseUrl/patients/profile",

        data: {
          "name": name,
          "phone": phone,
          "location": location,
          "dateOfBirth": dateOfBirth,
        },

        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.data;
    } on DioException catch (e) {
      print(e.response?.data);

      throw Exception(
        e.response?.data["message"] ?? "Failed to update patient profile",
      );
    }
  }

  // =========================
  // GET DOCTOR PROFILE
  // =========================
  Future<Map<String, dynamic>> getDoctorProfile() async {
    try {
      final token = await getToken();

      final response = await dio.get(
        "$baseUrl/doctors/profile",

        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.data;
    } on DioException catch (e) {
      print(e.response?.data);

      throw Exception(
        e.response?.data["message"] ?? "Failed to load doctor profile",
      );
    }
  }

  // =========================
  // UPDATE DOCTOR PROFILE
  // =========================
  Future<Map<String, dynamic>> updateDoctorProfile({
    required String phone,
    required String location,
    required String specialization,
    required String university,
    required String certificate,
    required String about,
    required String fees,
  }) async {
    try {
      final token = await getToken();

      final response = await dio.put(
        "$baseUrl/doctors/profile",

        data: {
          "phone": phone,
          "clinicLocation": location,
          "specialization": specialization,
          "university": university,
          "certificate": certificate,
          "about": about,
          "fees": fees,
        },

        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.data;
    } on DioException catch (e) {
      print(e.response?.data);

      throw Exception(
        e.response?.data["message"] ?? "Failed to update doctor profile",
      );
    }
  }

  // =========================
  // UPLOAD DOCTOR IMAGE
  // =========================
  Future<String> uploadDoctorImage(File imageFile) async {
    try {
      final token = await getToken();

      String fileName = imageFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        "$baseUrl/doctors/upload-image",

        data: formData,

        options: Options(
          headers: {
            "Authorization": "Bearer $token",

            "Content-Type": "multipart/form-data",
          },
        ),
      );

      return response.data["imageUrl"] ?? '';
    } on DioException catch (e) {
      print(e.response?.data);

      throw Exception(e.response?.data["message"] ?? "Image upload failed");
    }
  }

  // =========================
  // UPLOAD PATIENT IMAGE
  // =========================
  Future<String> uploadPatientImage(File imageFile) async {
    try {
      final token = await getToken();

      String fileName = imageFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        "$baseUrl/patients/upload-image",

        data: formData,

        options: Options(
          headers: {
            "Authorization": "Bearer $token",

            "Content-Type": "multipart/form-data",
          },
        ),
      );

      return response.data["imageUrl"] ?? '';
    } on DioException catch (e) {
      print(e.response?.data);

      throw Exception(e.response?.data["message"] ?? "Image upload failed");
    }
  }
}
