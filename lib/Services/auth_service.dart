import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {

  final dio.Dio dioClient = dio.Dio(

    dio.BaseOptions(

      connectTimeout:
          const Duration(seconds: 30),

      receiveTimeout:
          const Duration(seconds: 30),

      sendTimeout:
          const Duration(seconds: 30),

      headers: {
        "Content-Type":
            "application/json",
      },
    ),
  );

  final storage =
      const FlutterSecureStorage();


  static const baseUrl =
      "http://192.168.1.11:5000/api";

  // =========================
  // LOGIN
  // =========================
  Future<Map<String, dynamic>> login({

    required String email,
    required String password,

  }) async {

    try {

      final response =
          await dioClient.post(

        "$baseUrl/auth/login",

        data: {

          "email": email,
          "password": password,
        },
      );

      if (response.data["success"]
          != true) {

        throw Exception(
          "Login failed",
        );
      }

      final token =
          response.data["data"]["token"];

      await storage.write(

        key: "token",
        value: token,
      );

      return response.data;

    } on dio.DioException catch (e) {

      throw Exception(

        e.response?.data?["message"] ??
            "Connection Error",
      );
    }
  }

  // =========================
  // PATIENT SIGNUP
  // =========================
  Future<Map<String, dynamic>>
      patientSignup({

    required String name,
    required String email,
    required String phone,
    required String password,

  }) async {

    try {

      final response =
          await dioClient.post(

        "$baseUrl/auth/register",

        data: {

          "name": name,
          "email": email,
          "password": password,
          "role": "patient",
        },
      );

      final token =
          response.data["data"]["token"];

      await storage.write(

        key: "token",
        value: token,
      );

      return response.data;

    } on dio.DioException catch (e) {

      throw Exception(

        e.response?.data.toString() ??
            "Patient signup failed",
      );
    }
  }

  // =========================
  // DOCTOR SIGNUP
  // =========================
  Future<Map<String, dynamic>>
      doctorSignup({

    required String name,
    required String email,
    required String password,
    required String phone,
    required String specialization,
    required String clinicLocation,
    required String fees,

  }) async {

    try {

      final response =
          await dioClient.post(

        "$baseUrl/auth/register",

        data: {

          "name": name,
          "email": email,
          "password": password,
          "role": "doctor",
        },
      );

      final token =
          response.data["data"]["token"];

      await storage.write(

        key: "token",
        value: token,
      );

      return response.data;

    } on dio.DioException catch (e) {

      throw Exception(

        e.response?.data.toString() ??
            "Doctor signup failed",
      );
    }
  }

  // =========================
  // GET TOKEN
  // =========================
  Future<String?> getToken() async {

    return await storage.read(
      key: "token",
    );
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {

    await storage.delete(
      key: "token",
    );
  }

  // =========================
  // GET DOCTOR PROFILE
  // =========================
  Future<Map<String, dynamic>>
      getDoctorProfile() async {

    try {

      final token =
          await getToken();

      final response =
          await dioClient.get(

        "$baseUrl/doctors/profile",

        options: dio.Options(

          headers: {

            "Authorization":
                "Bearer $token",
          },
        ),
      );

      return response.data;

    } on dio.DioException catch (e) {

      throw Exception(

        e.response?.data?["message"] ??
            "Failed to load doctor profile",
      );
    }
  }

  // =========================
  // UPDATE DOCTOR PROFILE
  // =========================
  Future<Map<String, dynamic>>
      updateDoctorProfile({

    required String phone,
    required String location,
    required String specialization,
    required String university,
    required String certificate,
    required String about,
    required String fees,

    String? imageUrl,

  }) async {

    try {

      final token =
          await getToken();

      final Map<String, dynamic>
          data = {

        "phone": phone,

        "clinicLocation":
            location,

        "specialization":
            specialization,

        "university":
            university,

        "certificate":
            certificate,

        "about": about,

        "fees":
            int.tryParse(fees) ?? 0,
      };

      if (imageUrl != null &&
          imageUrl.isNotEmpty) {

        data["imageUrl"] =
            imageUrl;
      }

      final response =
          await dioClient.put(

        "$baseUrl/doctors/profile",

        data: data,

        options: dio.Options(

          headers: {

            "Authorization":
                "Bearer $token",
          },
        ),
      );

      return response.data;

    } on dio.DioException catch (e) {

      throw Exception(

        e.response?.data?["message"] ??
            "Failed to update doctor profile",
      );
    }
  }

  // =========================
// UPLOAD DOCTOR IMAGE
// =========================
Future<String> uploadDoctorImage(
  File imageFile,
) async {

  try {

    final token = await getToken();

    String fileName =
        imageFile.path
            .split('/')
            .last;

    dio.FormData formData =
        dio.FormData.fromMap({

      "image":
          await dio.MultipartFile
              .fromFile(

        imageFile.path,

        filename: fileName,
      ),
    });

    final response =
        await dioClient.post(

      "$baseUrl/doctors/upload-image",

      data: formData,

      options: dio.Options(

        headers: {

          "Authorization":
              "Bearer $token",

          "Content-Type":
              "multipart/form-data",
        },
      ),
    );

    print("UPLOAD RESPONSE:");
    print(response.data);

    // =========================
    // مهم جداً
    // =========================

    if (response.data["imageUrl"] != null) {

      return response.data["imageUrl"];
    }

    if (response.data["data"] != null &&
        response.data["data"]["imageUrl"] != null) {

      return response.data["data"]["imageUrl"];
    }

    throw Exception(
      "Image url not returned from backend",
    );

  } on dio.DioException catch (e) {

    throw Exception(

      e.response?.data?["message"] ??
          "Image upload failed",
    );
  }
}
  // =========================
  // GET PATIENT PROFILE
  // =========================
  Future<Map<String, dynamic>>
      getPatientProfile() async {

    try {

      final token =
          await getToken();

      final response =
          await dioClient.get(

        "$baseUrl/patients/profile",

        options: dio.Options(

          headers: {

            "Authorization":
                "Bearer $token",
          },
        ),
      );

      return response.data;

    } on dio.DioException catch (e) {

      throw Exception(

        e.response?.data?["message"] ??
            "Failed to load patient profile",
      );
    }
  }

  // =========================
  // UPDATE PATIENT PROFILE
  // =========================
  Future<Map<String, dynamic>>
      updatePatientProfile({

    required String name,
    required String phone,
    required String location,
    required String dateOfBirth,

  }) async {

    try {

      final token =
          await getToken();

      final response =
          await dioClient.put(

        "$baseUrl/patients/profile",

        data: {

          "name": name,
          "phone": phone,
          "location": location,
          "dateOfBirth":
              dateOfBirth,
        },

        options: dio.Options(

          headers: {

            "Authorization":
                "Bearer $token",
          },
        ),
      );

      return response.data;

    } on dio.DioException catch (e) {

      throw Exception(

        e.response?.data?["message"] ??
            "Failed to update patient profile",
      );
    }
  }

  // =========================
  // UPLOAD PATIENT IMAGE
  // =========================
  
}