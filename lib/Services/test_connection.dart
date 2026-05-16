import 'package:dio/dio.dart';

void testConnection() async {
  try {
    final response = await Dio().get("http://192.168.1.16:5000/health");

    print("SUCCESS:");
    print(response.data);
  } catch (e) {
    print("FAILED:");
    print(e);
  }
}
