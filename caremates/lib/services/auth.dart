import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  static final storage = FlutterSecureStorage();

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];
        await storage.write(key: 'access_token', value: accessToken);
        return accessToken != null; // true if token exists
      } else {
        // print('Login failed: ${response.body}');
        return false;
      }
    } catch (e) {
      // print('Error during login: $e');
      return false;
    }
  }

  static Future<bool> register({
    required String nama,
    required String email,
    required String noTelepon,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        },
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'no_telepon': "08123456789",
          'password': password,
          'role': "caregiver",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];
        await storage.write(key: 'access_token', value: accessToken);
        // print("Registered! Token: $token");
        return true;
      } else {
        // print("Register failed: ${response.body}");
        return false;
      }
    } catch (e) {
      // print("Register error: $e");
      throw Exception("Failed to register");
    }
  }

  static Future<bool> logout() async {
    try {
      await storage.delete(key: 'access_token');
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await storage.read(key: 'access_token');

    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
}
