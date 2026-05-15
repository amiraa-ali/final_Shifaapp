import 'package:dio/dio.dart';

import 'auth_service.dart';

class ChatService {
  final Dio dio = Dio();

  final AuthService _authService = AuthService();

  static const baseUrl = "http://10.0.2.2:5000/api";

  // =========================
  // GET CHAT MESSAGES
  // =========================
  Future<List<dynamic>> getMessages(String chatId) async {
    try {
      final token = await _authService.getToken();

      final response = await dio.get(
        "$baseUrl/chat/$chatId/messages",

        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.data["messages"] ?? [];
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Failed to load messages");
    }
  }

  // =========================
  // SEND MESSAGE
  // =========================
  Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String receiverId,
    required String message,
  }) async {
    try {
      final token = await _authService.getToken();

      final response = await dio.post(
        "$baseUrl/chat/send",

        data: {"chatId": chatId, "receiverId": receiverId, "message": message},

        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Failed to send message");
    }
  }

  // =========================
  // GET USER CHATS
  // =========================
  Future<List<dynamic>> getChats() async {
    try {
      final token = await _authService.getToken();

      final response = await dio.get(
        "$baseUrl/chat",

        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.data["chats"] ?? [];
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Failed to load chats");
    }
  }

  // =========================
  // MARK AS READ
  // =========================
  Future<void> markAsRead(String chatId) async {
    try {
      final token = await _authService.getToken();

      await dio.put(
        "$baseUrl/chat/$chatId/read",

        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Failed to mark messages as read",
      );
    }
  }

  // =========================
  // DELETE MESSAGE
  // =========================
  Future<void> deleteMessage(String messageId) async {
    try {
      final token = await _authService.getToken();

      await dio.delete(
        "$baseUrl/chat/message/$messageId",

        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Failed to delete message",
      );
    }
  }
}
